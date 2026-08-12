# Your Portion Admin Dashboard

Next.js 15 admin dashboard with Tailwind CSS, deployable to Cloudflare Pages/Workers. Zero Express — uses native Next.js Route Handlers (Web Request/Response API).

## Local Development

### Prerequisites

- **Node.js 18.18+** (Node 20 LTS recommended)
- **npm** (comes with Node.js)
- A **Supabase** project (URL + service role key) — the dashboard reads/writes data through it

### 1. Install dependencies

```bash
npm install
```

### 2. Configure environment variables

Copy the example env file and fill in the values:

```bash
cp .env.example .env
```

Or run the interactive setup script (prompts for each value and auto-generates `JWT_SECRET`):

```bash
npm run setup
```

Required variables (see [.env](#env) table below):

| Variable | How to get it |
|----------|---------------|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase → Project Settings → API → Project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase → Project Settings → API → `service_role` secret (bypasses RLS) |
| `ADMIN_USERNAME` | Your admin login username |
| `ADMIN_PASSWORD_HASH` | Admin login password (plain text, compared directly) |
| `JWT_SECRET` | Any random string; the setup script generates one automatically |

Optional notification variables (enable email/push to app users):

| Variable | How to get it |
|----------|---------------|
| `SMTP_URL` | HTTP endpoint accepting `{ from, to, subject, text }` (e.g. a Mailgun/Mailjet relay) |
| `NOTIFICATION_EMAIL_FROM` | Sender address used in email notifications |
| `FCM_SERVICE_ACCOUNT` | Firebase service account JSON (one line) — FCM HTTP v1 push |
| `FCM_SERVER_KEY` | *(deprecated by Google)* legacy FCM server key — only used as fallback |

### 3. Start the dev server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000). The default port is `3000`; use `npm run dev -- -p 4000` to change it.

### 4. Log in

Use the credentials you set in `ADMIN_USERNAME` / `ADMIN_PASSWORD_HASH`. You should land on `/dashboard` with live data from your Supabase project.

## .env

| Variable | Description |
|----------|-------------|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service_role key (bypasses RLS) |
| `ADMIN_USERNAME` | Admin login username |
| `ADMIN_PASSWORD_HASH` | Admin login password (plain text, compared directly) |
| `JWT_SECRET` | Random string for signing JWT tokens |
| `SMTP_URL` | *(optional)* HTTP email relay endpoint for notifications |
| `NOTIFICATION_EMAIL_FROM` | *(optional)* Sender address for email notifications |
| `FCM_SERVICE_ACCOUNT` | *(optional)* Firebase service account JSON (FCM HTTP v1 push) |
| `FCM_SERVER_KEY` | *(optional, deprecated)* Legacy FCM key — fallback only |

## Pages

| Route | Description |
|-------|-------------|
| `/` | Login page |
| `/dashboard` | Overview with pending counts + quick actions |
| `/verification` | Seller / Trusted Member requests with filters, document review, approve / reject / terminate |
| `/properties` | Property approval list |
| `/projects` | Kingdom project approval list with progress bars |

## API Routes

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/login` | POST | Admin login |
| `/api/dashboard` | GET | Dashboard stats |
| `/api/verification/requests` | GET | List verification requests (optional `requestType`, `status` filters) |
| `/api/verification/approve` | POST | Approve verification + notify the user |
| `/api/verification/reject` | POST | Reject verification + notify the user |
| `/api/verification/terminate` | POST | Revoke verified status + notify the user |
| `/api/storage/[...path]` | GET | Proxy document images/PDFs from Supabase Storage |
| `/api/properties/pending` | GET | List pending properties |
| `/api/properties/approve` | POST | Approve property |
| `/api/properties/reject` | POST | Reject property |
| `/api/projects/pending` | GET | List pending projects |
| `/api/projects/approve` | POST | Approve project |
| `/api/projects/reject` | POST | Reject project |

## Database Setup

The dashboard expects the `verification_requests` table, `notifications` table, `device_tokens` table, and the `verification_documents` storage bucket. Run these migrations in the Supabase SQL Editor (idempotent — safe to re-run):

1. `supabase/migrations/00009_verification_setup.sql` — verification requests table, RLS, storage bucket + policies
2. `supabase/migrations/00010_notifications_and_termination.sql` — notifications table, realtime, termination columns
3. `supabase/migrations/00011_device_tokens.sql` — FCM device tokens for push notifications

Until `00009` is applied, the storage proxy returns **`Bucket not found`** and document review won't work.

## Push Notifications Setup (FCM)

1. **Create a Firebase project** at [console.firebase.google.com](https://console.firebase.google.com) → **Add project**.
2. **Add your app**: Android (package `com.example.your_portion`) and iOS (bundle id) — download and drop `google-services.json` into `android/app/` and `GoogleService-Info.plist` into `ios/Runner/`.
3. **Install FlutterFire**: in the project root run `flutterfire configure` (installs the Flutter CLI plugin and generates `lib/firebase_options.dart`), or simply keep the guarded `PushNotificationService` — it activates automatically once Firebase is configured.
4. **Get the service account key**: Firebase console → ⚙️ Project settings → **Service accounts** → **Generate new private key**. Paste the JSON into the `FCM_SERVICE_ACCOUNT` env var (single line).
5. **Run migration 00011** so the app can store its device token.
6. Push requires a physical device/emulator with Google Play services — it does **not** work on Flutter web.

When an admin approves, rejects, or terminates a verification, the user receives: an in-app notification (via Postgres realtime — works everywhere), an email (if `SMTP_URL` is set), and a push (if Firebase is configured).

## Deploy to Cloudflare Pages

```bash
npm run build       # Build with next-on-pages adapter
npm run deploy      # Deploy to Cloudflare Pages
npm run preview     # Preview locally with wrangler
```

### Manual Cloudflare Setup

1. Go to [dash.cloudflare.com](https://dash.cloudflare.com) → **Pages** → **Create a project** → **Connect to Git**
2. Select your repo, set:
   - **Build command**: `npm run build`
   - **Build output directory**: `.vercel/output/static`
3. Add these environment variables:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `ADMIN_USERNAME`
   - `ADMIN_PASSWORD_HASH`
   - `JWT_SECRET`
   - *(optional, for notifications)* `SMTP_URL`, `NOTIFICATION_EMAIL_FROM`, `FCM_SERVICE_ACCOUNT`
4. Deploy — Cloudflare Workers runtime handles the API routes.

## Architecture

```
User → Cloudflare Pages
         ├── Static assets (Next.js output)
         └── API routes (Workers runtime)
                  ├── /api/auth/*        — JWT auth
                  ├── /api/dashboard     — Pending counts
                  ├── /api/verification/*— Approve/reject/terminate + notify users
                  ├── /api/storage/*     — Document proxy from Supabase Storage
                  ├── /api/properties/*  — Approve/reject listings
                  └── /api/projects/*    — Approve/reject projects
                           └── All routes → Supabase REST API (service_role key)
```

Admin authenticates via JWT (jose). All data operations use the Supabase admin client with the service role key, bypassing RLS. Approve / reject / terminate write an in-app notification (and optionally email/push) that the Flutter app receives in real time via Postgres realtime.

## Login

Default after setup: username from `ADMIN_USERNAME`, password from `ADMIN_PASSWORD_HASH`.
