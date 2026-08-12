# Your Portion — Faith-Centered Marketplace

> **AI assistants**: Before making changes, read all files in `docs/` for project context (PRD, tech stack, implementation, progress, rules, architecture).

Flutter mobile app (Android/iOS/macOS) with a standalone web admin dashboard.

## Quick Start (Flutter App)

```sh
flutter pub get
cp assets/.env.example assets/.env   # fill in Supabase credentials
flutter run
```

## Quick Start (Admin Dashboard)

```sh
cd admin-dashboard
npm install
cp .env.example .env   # fill in Supabase URL, service role key, admin credentials
npm run dev            # → http://localhost:3000
```

The admin dashboard is a separate web app — not a Flutter screen. See `admin-dashboard/README.md` and `docs/ARCHITECTURE.md` for full details.

## Deploy Admin Dashboard (Cloudflare Pages)

```sh
cd admin-dashboard
npm install
npm run build     # build with next-on-pages adapter
npm run deploy    # deploy to Cloudflare Pages
```

Push to GitHub, then:

- **Cloudflare Pages**: New Project → Connect to Git → Build command = `npm run build` → Build output directory = `.vercel/output/static`
- **Render / Railway**: Root Directory = `admin-dashboard` → Build = `npm install` → Start = `npm start` → Add env vars

Required env vars: `NEXT_PUBLIC_SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `ADMIN_USERNAME`, `ADMIN_PASSWORD_HASH`, `JWT_SECRET`. Optional: `SMTP_URL`, `NOTIFICATION_EMAIL_FROM`, `FCM_SERVICE_ACCOUNT` (notifications).

## Database Setup

Run the idempotent migrations in Supabase → SQL Editor (in order):

1. `supabase/migrations/00009_verification_setup.sql` — verification requests + storage bucket
2. `supabase/migrations/00010_notifications_and_termination.sql` — notifications + verification termination
3. `supabase/migrations/00011_device_tokens.sql` — FCM device tokens for push notifications
