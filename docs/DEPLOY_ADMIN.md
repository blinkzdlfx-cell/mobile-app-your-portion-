# Deploying the Admin Dashboard

The admin dashboard is a **Next.js 15 app** with Tailwind CSS, deployed to Cloudflare Pages (static output) with Cloudflare Workers (API routes). No Express server.

## How It Works

```
User → Cloudflare Pages
         ├── / → static Next.js output (Login, Dashboard, Verification, Properties, Projects)
         └── /api/* → Workers runtime (Next.js Route Handlers)
                        └── calls Supabase REST API via @supabase/supabase-js (service_role key)
```

## Prerequisites

1. **Supabase project** with all 6 migration SQL files executed
2. **Node.js 18+** installed locally

## Required Environment Variables

| Variable | Description | Source |
|----------|-------------|--------|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL | Supabase Dashboard → Settings → API |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key (bypasses RLS) | Supabase Dashboard → Settings → API |
| `ADMIN_USERNAME` | Admin login username | Choose any |
| `ADMIN_PASSWORD_HASH` | Admin password (plain text) | Choose any |
| `JWT_SECRET` | Random string for signing JWTs | `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"` |

## Deploy to Cloudflare Pages

### Option A: Wrangler CLI

```bash
cd admin-dashboard
npm install
npm run build
npm run deploy
```

### Option B: Cloudflare Dashboard (Git integration)

1. Go to [dash.cloudflare.com](https://dash.cloudflare.com) → **Pages** → **Create a project** → **Connect to Git**
2. Select your GitHub repository
3. Configure:
   - **Project name**: `your-portion-admin`
   - **Production branch**: `main`
   - **Build command**: `cd admin-dashboard && npm install && npm run build`
   - **Build output directory**: `admin-dashboard/.vercel/output/static`
4. Add environment variables (click **Add variable** for each):
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `ADMIN_USERNAME`
   - `ADMIN_PASSWORD_HASH`
   - `JWT_SECRET`
5. Click **Save and Deploy**
6. After deployment, open the generated `*.pages.dev` URL

### Option C: wrangler.toml (already configured)

The project includes a pre-configured `wrangler.toml`. Run:

```bash
cd admin-dashboard
npx wrangler pages deploy .vercel/output/static --project-name=your-portion-admin
```

## Verifying

1. Open the deployment URL — you should see the **Admin Login** page
2. Log in with your admin credentials (`ADMIN_USERNAME` / `ADMIN_PASSWORD_HASH`)
3. The dashboard shows pending counts (all zeros if no data yet)
4. Navigate between Dashboard, Verification, Properties, Projects

## Local Development

```bash
cd admin-dashboard
npm install
npm run setup   # interactive .env generator (or copy .env.example → .env)
npm run dev     # → http://localhost:3000
```

## Important Notes

- The service role key bypasses all RLS policies — **keep it secret**, never expose it client-side
- All 6 migration SQL files in `supabase/migrations/` **must be executed** in your Supabase SQL editor
- To update the admin password, change `ADMIN_PASSWORD_HASH` in env vars and redeploy
- Cloudflare Workers free tier: 100k requests/day, 10ms CPU per request
- If you see `SUPABASE_SERVICE_ROLE_KEY` errors, verify you're using the `service_role` key (not the `anon` public key) from Supabase Settings → API
