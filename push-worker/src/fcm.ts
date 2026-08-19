import { SignJWT, importPKCS8 } from 'jose'
import type { WorkerEnv } from './index'

export interface FcmResult {
  ok: boolean
  sent: number
  failed: number
  invalidTokens: string[]
  error?: string
}

// Same OAuth2 flow the admin dashboard uses (FCM HTTP v1). Cached across
// cron runs where possible; Workers isolate allow module-level state per isolate.
let oauthToken: { token: string; expiresAt: number } | null = null

interface FcmServiceAccount {
  project_id: string
  client_email: string
  private_key: string
}

function parseServiceAccount(raw: string): FcmServiceAccount | null {
  if (!raw) return null
  try {
    const account = JSON.parse(raw) as FcmServiceAccount
    if (!account.project_id || !account.client_email || !account.private_key) return null
    return account
  } catch {
    return null
  }
}

async function getAccessToken(env: WorkerEnv): Promise<string | null> {
  const account = parseServiceAccount(env.FCM_SERVICE_ACCOUNT)
  if (!account) return null

  if (oauthToken && oauthToken.expiresAt > Date.now() + 60_000) {
    return oauthToken.token
  }

  try {
    const key = await importPKCS8(account.private_key, 'RS256')
    const jwt = await new SignJWT({ scope: 'https://www.googleapis.com/auth/firebase.messaging' })
      .setProtectedHeader({ alg: 'RS256', typ: 'JWT' })
      .setIssuer(account.client_email)
      .setSubject(account.client_email)
      .setAudience('https://oauth2.googleapis.com/token')
      .setIssuedAt()
      .setExpirationTime('1h')
      .sign(key)

    const res = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${encodeURIComponent(jwt)}`,
    })
    if (!res.ok) return null

    const data = (await res.json()) as { access_token?: string; expires_in?: number }
    if (!data.access_token) return null

    oauthToken = {
      token: data.access_token,
      expiresAt: Date.now() + (data.expires_in ?? 3600) * 1000,
    }
    return oauthToken.token
  } catch {
    return null
  }
}

// FCM v1 error details (`error.details` array) — a token is stale when FCM
// reports it as unregistered/deprecated and asks us to stop sending to it.
function isUnregisteredError(code: number, details: unknown): boolean {
  if (code === 404) return true
  if (!Array.isArray(details)) return false
  return details.some(
    (d) =>
      d &&
      typeof d === 'object' &&
      'errorCode' in d &&
      (d.errorCode === 'UNREGISTERED' || d.errorCode === 'SENDER_ID_MISMATCH'),
  )
}

async function sendOne(
  accessToken: string,
  projectId: string,
  token: string,
  title: string,
  body: string,
): Promise<{ ok: boolean; unregistered: boolean }> {
  try {
    const res = await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data: { type: 'daily_portion' },
        },
      }),
    })
    if (res.ok) return { ok: true, unregistered: false }

    let details: unknown
    try {
      const json = (await res.json()) as { error?: { details?: unknown } }
      details = json?.error?.details
    } catch {
      details = undefined
    }
    return { ok: false, unregistered: isUnregisteredError(res.status, details) }
  } catch {
    return { ok: false, unregistered: false }
  }
}

/**
 * Fans out one notification to every device token. Token lists can be large,
 * so sends are batched (25 at a time) instead of one giant Promise.all.
 */
export async function sendDailyPush(
  env: WorkerEnv,
  tokens: string[],
  title: string,
  body: string,
): Promise<FcmResult> {
  const account = parseServiceAccount(env.FCM_SERVICE_ACCOUNT)
  if (!account) return { ok: false, sent: 0, failed: 0, invalidTokens: [], error: 'FCM_SERVICE_ACCOUNT not configured' }

  const accessToken = await getAccessToken(env)
  if (!accessToken) return { ok: false, sent: 0, failed: 0, invalidTokens: [], error: 'FCM OAuth token mint failed' }

  const result: FcmResult = { ok: true, sent: 0, failed: 0, invalidTokens: [] }
  const batchSize = 25

  for (let i = 0; i < tokens.length; i += batchSize) {
    const batch = tokens.slice(i, i + batchSize)
    const outcomes = await Promise.all(batch.map((t) => sendOne(accessToken, account.project_id, t, title, body)))
    for (let j = 0; j < outcomes.length; j++) {
      if (outcomes[j].ok) {
        result.sent++
      } else {
        result.failed++
        if (outcomes[j].unregistered) result.invalidTokens.push(batch[j])
      }
    }
  }

  if (result.failed > 0 && result.sent === 0) result.ok = false
  return result
}