import { getSupabase } from './supabase'
import type { SupabaseClient } from '@supabase/supabase-js'
import { SignJWT, importPKCS8 } from 'jose'

export type NotificationChannel = 'in_app' | 'push' | 'email'

interface NotifyOptions {
  userId: string
  type: string
  title: string
  message: string
  channels?: NotificationChannel[]
}

async function sendEmail(sb: SupabaseClient, toUserId: string, subject: string, body: string): Promise<boolean> {
  const from = process.env.NOTIFICATION_EMAIL_FROM
  const smtpUrl = process.env.SMTP_URL
  if (!from || !smtpUrl) return false

  const { data: profile } = await sb
    .from('profiles')
    .select('email')
    .eq('id', toUserId)
    .maybeSingle()
  const to = profile?.email
  if (!to) return false

  try {
    const res = await fetch(smtpUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ from, to, subject, text: body }),
    })
    return res.ok
  } catch {
    return false
  }
}

interface FcmServiceAccount {
  project_id: string
  client_email: string
  private_key: string
}

let _oauthToken: { token: string; expiresAt: number } | null = null

// FCM HTTP v1 requires an OAuth2 access token minted from the Firebase
// service account JSON (signed JWT, RS256). Tokens live ~1h — cache them.
async function getFcmAccessToken(): Promise<string | null> {
  const raw = process.env.FCM_SERVICE_ACCOUNT
  if (!raw) return null

  let account: FcmServiceAccount
  try {
    account = JSON.parse(raw) as FcmServiceAccount
  } catch {
    console.error('FCM_SERVICE_ACCOUNT is not valid JSON')
    return null
  }
  if (!account.project_id || !account.client_email || !account.private_key) return null

  if (_oauthToken && _oauthToken.expiresAt > Date.now() + 60_000) {
    return _oauthToken.token
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

    _oauthToken = {
      token: data.access_token,
      expiresAt: Date.now() + ((data.expires_in ?? 3600) * 1000),
    }
    return _oauthToken.token
  } catch (e) {
    console.error('Failed to get FCM access token', e)
    return null
  }
}

async function sendPushV1(sb: SupabaseClient, toUserId: string, title: string, body: string): Promise<boolean> {
  const accessToken = await getFcmAccessToken()
  const projectId = getFcmProjectId()
  if (!accessToken || !projectId) return false

  const { data: deviceTokens } = await sb
    .from('device_tokens')
    .select('token')
    .eq('user_id', toUserId)
  if (!deviceTokens?.length) return false

  try {
    const results = await Promise.all(
      (deviceTokens as { token: string }[]).map((t) =>
        fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${accessToken}`,
          },
          body: JSON.stringify({
            message: {
              token: t.token,
              notification: { title, body },
              data: { type: 'notification' },
            },
          }),
        }).then((r) => r.ok)
      )
    )
    return results.some(Boolean)
  } catch {
    return false
  }
}

function getFcmProjectId(): string | null {
  try {
    const account = JSON.parse(process.env.FCM_SERVICE_ACCOUNT || '') as FcmServiceAccount
    return account.project_id || null
  } catch {
    return null
  }
}

// Legacy fallback (deprecated by Google) — kept only if FCM_SERVER_KEY is set.
async function sendPushLegacy(sb: SupabaseClient, toUserId: string, title: string, body: string): Promise<boolean> {
  const fcmServerKey = process.env.FCM_SERVER_KEY
  if (!fcmServerKey) return false

  const { data: deviceTokens } = await sb
    .from('device_tokens')
    .select('token')
    .eq('user_id', toUserId)
  if (!deviceTokens?.length) return false

  try {
    const results = await Promise.all(
      (deviceTokens as { token: string }[]).map((t) =>
        fetch('https://fcm.googleapis.com/fcm/send', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `key=${fcmServerKey}`,
          },
          body: JSON.stringify({
            to: t.token,
            notification: { title, body },
            data: { type: 'notification' },
          }),
        }).then((r) => r.ok)
      )
    )
    return results.some(Boolean)
  } catch {
    return false
  }
}

async function sendPush(sb: SupabaseClient, toUserId: string, title: string, body: string): Promise<boolean> {
  if (process.env.FCM_SERVICE_ACCOUNT) return sendPushV1(sb, toUserId, title, body)
  return sendPushLegacy(sb, toUserId, title, body)
}

export async function notifyUser({ userId, type, title, message, channels = ['in_app'] }: NotifyOptions) {
  const sb = getSupabase()
  const results: Record<string, boolean> = {}

  if (channels.includes('in_app')) {
    const { error } = await sb.from('notifications').insert({
      user_id: userId,
      type,
      channel: 'in_app',
      title,
      message,
    })
    results.in_app = !error
  }

  if (channels.includes('email')) {
    results.email = await sendEmail(sb, userId, title, message)
  }

  if (channels.includes('push')) {
    results.push = await sendPush(sb, userId, title, message)
  }

  return results
}
