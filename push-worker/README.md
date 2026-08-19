# Your Portion — Push Worker (Cloudflare)

Daily scheduled Cloudflare Worker: posts the day's portion from the write-ahead
queue, pushes it to every registered device via FCM, prunes dead tokens, logs
deliveries — and keeps Supabase awake for free (each run touches the DB).

## Prerequisites

1. Run `supabase/migrations/00015_push_worker.sql` in the Supabase SQL Editor
   (creates `push_logs`, the `claim_oldest_portion()` function, and restricts
   it to the service-role key).
2. You need the FCM service account JSON (Firebase console → Project settings →
   Service accounts → Generate new private key). The admin dashboard uses the
   same key via `FCM_SERVICE_ACCOUNT` if notifications are already working.

## Local dev

```sh
npm install
npx wrangler dev
```

Then hit `http://localhost:8787/run` to run the job manually. Secrets are read
from `.dev.vars` in dev:

```sh
# push-worker/.dev.vars (gitignored, never commit)
SUPABASE_SERVICE_ROLE_KEY=eyJ...
FCM_SERVICE_ACCOUNT={"project_id":"...","client_email":"...","private_key":"-----BEGIN PRIVATE KEY-----..."}
```

## Deploy

```sh
npm run deploy        # wrangler deploy
wrangler secret put SUPABASE_SERVICE_ROLE_KEY
wrangler secret put FCM_SERVICE_ACCOUNT
```

`grants` the scheduled trigger: the Worker runs at 06:00 UTC daily
(`[triggers].crons` in `wrangler.toml`). Workers support a maximum of 1-minute
granularity on the free plan — a daily 06:00 run is fine.

## Verify

After deploying, open your worker URL (found in the Cloudflare dashboard) —
`https://your-portion-push-worker.<account>.workers.dev/run` runs the job on
demand and returns a JSON summary:

```json
{
  "status": "ok",
  "portionId": "...",
  "portionTitle": "...",
  "recipients": 3,
  "sent": 3,
  "failed": 0,
  "logId": "...",
  "ranAt": "..."
}
```

Check delivery history in the `push_logs` table (Supabase → Table Editor).

## Idempotency

- `claim_oldest_portion()` refuses to publish when a portion already has
  today's date (unique partial index from migration `00014` + a re-check inside
  the function). Manual `/run` clicks are safe.
- No outstanding draft → status `no_portion`, no push, still logged.

## Replacing GitHub Actions keep-alive

Once the cron has run once, delete these workflows (they only ping weekly):
`.github/workflows/supabase-keep-alive.yml` and
`.github/workflows/supabase_keep_alive.yml`. Keep `.github/workflows/ci.yml`.