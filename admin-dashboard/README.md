# Your Portion Admin Dashboard

Next.js 15 admin dashboard with Tailwind CSS, deployable to Cloudflare Pages/Workers. Zero Express — uses native Next.js Route Handlers (Web Request/Response API).

## Quick Start

```bash
npm install
npm run setup      # interactive .env generator
npm run dev        # → http://localhost:3000
```

## .env

| Variable | Description |
|----------|-------------|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service_role key (bypasses RLS) |
| `ADMIN_USERNAME` | Admin login username |
| `ADMIN_PASSWORD_HASH` | Admin password (plain text) |
| `JWT_SECRET` | Random string for signing JWT tokens |

## Pages

| Route | Description |
|-------|-------------|
| `/` | Login page |
| `/dashboard` | Overview with pending counts + quick actions |
| `/verification` | Seller / Trusted Member requests with filters |
| `/properties` | Property approval list |
| `/projects` | Kingdom project approval list with progress bars |

## API Routes

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/login` | POST | Admin login |
| `/api/dashboard` | GET | Dashboard stats |
| `/api/verification/requests` | GET | List verification requests |
| `/api/verification/approve` | POST | Approve verification |
| `/api/verification/reject` | POST | Reject verification |
| `/api/properties/pending` | GET | List pending properties |
| `/api/properties/approve` | POST | Approve property |
| `/api/properties/reject` | POST | Reject property |
| `/api/projects/pending` | GET | List pending projects |
| `/api/projects/approve` | POST | Approve project |
| `/api/projects/reject` | POST | Reject project |

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
4. Deploy — Cloudflare Workers runtime handles the API routes.

## Architecture

```
User → Cloudflare Pages
         ├── Static assets (Next.js output)
         └── API routes (Workers runtime)
                  ├── /api/auth/*        — JWT auth
                  ├── /api/dashboard     — Pending counts
                  ├── /api/verification/*— Approve/reject requests
                  ├── /api/properties/*  — Approve/reject listings
                  └── /api/projects/*    — Approve/reject projects
                           └── All routes → Supabase REST API (service_role key)
```

Admin authenticates via JWT (jose). All data operations use the Supabase admin client with the service role key, bypassing RLS.

## Login

Default after setup: username from `ADMIN_USERNAME`, password from `ADMIN_PASSWORD_HASH`.
