import { createClient } from '@supabase/supabase-js'
import { sendDailyPush, type FcmResult } from './fcm'

export interface WorkerEnv {
  NEXT_PUBLIC_SUPABASE_URL: string
  SUPABASE_SERVICE_ROLE_KEY: string
  FCM_SERVICE_ACCOUNT: string
}

interface ClaimedPortion {
  id: string
  title: string
  scripture_reference: string | null
  content: string
}

interface RunSummary {
  status: 'ok' | 'no_portion' | 'error'
  portionId?: string | null
  portionTitle?: string | null
  recipients?: number
  sent?: number
  failed?: number
  removedStaleTokens?: number
  error?: string
  logId?: string | null
  ranAt: string
}

function excerpt(content: string, max = 140): string {
  return content
    .replace(/[#*_>|`-]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .slice(0, max)
}

function todayUtc(): string {
  return new Date().toISOString().slice(0, 10)
}

/**
 * The daily job — one run posts today's portion, pushes it to every registered
 * device, prunes stale FCM tokens and logs the outcome. Every run touches the
 * database, which keeps the Supabase free tier awake (no separate keep-alive).
 */
async function runDailyPush(env: WorkerEnv): Promise<RunSummary> {
  const summary: RunSummary = { status: 'ok', ranAt: new Date().toISOString() }
  const supabase = createClient(env.NEXT_PUBLIC_SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY)

  try {
    // 1) Claim today's portion (atomic + idempotent, enforced in SQL).
    const { data: claimed, error: claimError } = await supabase.rpc('claim_oldest_portion')
    if (claimError) throw claimError

    const portion = ((claimed as ClaimedPortion[] | null) ?? [])[0] ?? null
    if (!portion) {
      summary.status = 'no_portion'
      const { data: log, error: logError } = await supabase
        .from('push_logs')
        .insert({ status: 'no_portion' })
        .select('id')
        .single()
      if (!logError) summary.logId = log?.id ?? null
      return summary
    }

    summary.portionId = portion.id
    summary.portionTitle = portion.title

    // 2) Send the push to every registered device.
    const title = portion.title
    const body = portion.scripture_reference
      ? `\u{1F4D6} ${portion.scripture_reference} \u2014 ${excerpt(portion.content)}`
      : `Today's portion: ${excerpt(portion.content)}`

    const { data: tokens } = await supabase.from('device_tokens').select('token')
    const tokenList = (tokens ?? []).map((t) => t.token as string)
    summary.recipients = tokenList.length

    const result: FcmResult = tokenList.length
      ? await sendDailyPush(env, tokenList, title, body)
      : { ok: true, sent: 0, failed: 0, invalidTokens: [] }
    summary.sent = result.sent
    summary.failed = result.failed

    // 3) Prune stale tokens so we don't pay for dead sends each day.
    if (result.invalidTokens.length > 0) {
      const { data: removed } = await supabase
        .from('device_tokens')
        .delete()
        .in('token', result.invalidTokens)
        .select('id')
      summary.removedStaleTokens = removed?.length ?? 0
    }

    // 4) Log the delivery outcome.
    const { data: log, error } = await supabase
      .from('push_logs')
      .insert({
        portion_id: portion.id,
        status: result.failed > 0 ? 'error' : 'ok',
        recipients: summary.recipients,
        sent: result.sent,
        failed: result.failed,
        error: result.error ?? null,
      })
      .select('id')
      .single()
    if (error) {
      summary.error = `push_logs insert: ${error.message}`
      summary.status = 'error'
    } else {
      summary.logId = log?.id ?? null
      summary.status = result.failed > 0 ? 'error' : 'ok'
    }
    return summary
  } catch (e) {
    summary.status = 'error'
    const msg = (e as { message?: string })?.message ?? (e as { details?: string })?.details
    summary.error = msg || (typeof e === 'object' ? JSON.stringify(e) : String(e))
    return summary
  }
}

export default {
  async scheduled(_event: ScheduledEvent, env: WorkerEnv, ctx: ExecutionContext): Promise<void> {
    ctx.waitUntil(runDailyPush(env))
  },

  async fetch(request: Request, env: WorkerEnv): Promise<Response> {
    const url = new URL(request.url)

    // Manual trigger: GET / or GET /run?date=YYYY-MM-DD (uses real "today").
    if (url.pathname === '/' || url.pathname === '/run') {
      const summary = await runDailyPush(env)
      return new Response(JSON.stringify(summary, null, 2), {
        headers: { 'Content-Type': 'application/json' },
      })
    }

    if (url.pathname === '/health') {
      return new Response(
        JSON.stringify({ status: 'ok', nextRun: `0 6 * * * (UTC), today is ${todayUtc()}` }),
        { headers: { 'Content-Type': 'application/json' } },
      )
    }

    return new Response('Not found', { status: 404 })
  },
}