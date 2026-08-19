# Branch & Verify Workflow (REMEMBER THIS)

Applies to ALL future code edits after the baseline commit `ed52627`
(Android toolchain fix + skeleton loaders + push worker + migration 00015).

## The Rule
Never edit `main` directly for real changes.
1. Create a branch:        `git checkout -b <name>-<what>`
2. Make changes, commit them there.
3. VERIFY (checklist below).
4. Only after verification passes AND the human confirms it is OK,
   merge back:             `git checkout main; git merge <branch>; git push`

Baseline for comparison / rollback: `ed52627` on `main` (pushed to origin).

## Verification Checklist (run BEFORE merging)
Flutter app (any Dart/Android change):
    flutter analyze
    flutter test
    flutter build apk --debug        # confirms Gradle/Android still green
    # on a phone: flutter run and manually smoke-test the changed screen

Push worker (any push-worker/ change, from the push-worker/ dir):
    npx tsc --noEmit
    wrangler deploy -c wrangler.toml --dry-run
Administration dashboard (any admin-dashboard/ change):
    npm run build
    (or: npx tsc --noEmit  +  next lint)

Sequential only — NEVER run two `flutter` CLI commands in parallel
(they fight over the startup lock).

## Security gate (mandatory before every commit)
Confirm NOTHING secret is staged:
    git status --porcelain
    git diff --cached --name-only | Select-String 'env|service|token|secret|google-services'
Ignored & must NEVER be committed: assets/.env, admin-dashboard/.env,
push-worker/.dev.vars, push-worker/firebase-service-account.json,
android/app/google-services.json, ios/Runner/GoogleService-Info.plist,
*node_modules* and build artifacts (.wrangler-dist/, android/build/, /build/).

## Push worker deploy (still pending — for the deploy session)
1. Re-run supabase/migrations/00015_push_worker.sql in Supabase SQL Editor
   (it contains the `publish_date` ambiguity fix — HAS NOT been re-applied).
2. Verify a row exists in device_tokens (device added since ed52627).
3. wrangler login  (interactive, on this machine)
4. wrangler deploy -c wrangler.toml
5. wrangler secret put SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY / FCM_SERVICE_ACCOUNT
6. Test: hit the worker /run endpoint; confirm push_logs row + phone notification.
7. Once cron has fired once: delete .github/workflows/supabase-keep-alive.yml
   and supabase_keep_alive.yml, then update docs/PROGRESS.md.

## Why this flow exists
The repo history is production-oriented (previous commits shipped features
directly). From ed52627 forward every change is staged on a branch, proven
green, then merged — so a broken edit can never silently reach the pushed
main tree, and any agent can roll back to a known-good baseline.