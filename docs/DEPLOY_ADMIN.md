# Deploying the Admin Dashboard

The admin dashboard is a **Next.js 15 app** deployed to **Cloudflare Workers** using the `@opennextjs/cloudflare` adapter. No Express server.

## How It Works

```
User → Cloudflare Workers
         ├── / → static assets (HTML, CSS, JS)
         └── /api/* → Workers runtime (Next.js Route Handlers)
                        └── calls Supabase REST API via @supabase/supabase-js (service_role key)
```

## Prerequisites

1. **Supabase project** with all 8 migration SQL files executed
2. **Node.js 18+** installed locally (for local dev only)

## Required Environment Variables

| Variable | Description | Source |
|----------|-------------|--------|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL | Supabase Dashboard → Settings → API |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key (bypasses RLS) | Supabase Dashboard → Settings → API |
| `ADMIN_USERNAME` | Admin login username | Choose any |
| `ADMIN_PASSWORD_HASH` | Admin password (plain text) | Choose any |
| `JWT_SECRET` | Random string for signing JWTs | `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"` |

## Deploy via Cloudflare Dashboard (Git integration)

1. Go to [dash.cloudflare.com](https://dash.cloudflare.com) → **Workers & Pages** → **Create** → **Workers** → **Create Worker from a Git repository**
2. Select your GitHub repository
3. Configure:

   | Field | Value |
   |-------|-------|
   | **Project name** | `your-portion-admin` |
   | **Production branch** | `main` |
   | **Build command** | `cd admin-dashboard && npm install && npx opennextjs-cloudflare build` |
   | **Root directory** | *(leave blank)* |

4. Add environment variables (set `SUPABASE_SERVICE_ROLE_KEY`, `JWT_SECRET`, `ADMIN_PASSWORD_HASH` as **Encrypted/Secret**):

   | Variable | Encrypt? |
   |----------|----------|
   | `NEXT_PUBLIC_SUPABASE_URL` | No |
   | `SUPABASE_SERVICE_ROLE_KEY` | **Yes** |
   | `ADMIN_USERNAME` | No |
   | `ADMIN_PASSWORD_HASH` | **Yes** |
   | `JWT_SECRET` | **Yes** |

5. Click **Save and Deploy**
6. After deployment, open the generated `*.workers.dev` URL

## Local Development

```bash
cd admin-dashboard
cp .env.example .env   # fill in real keys
npm install
npm run dev            # Node.js dev server (fast hot-reload)
npm run preview        # Workers runtime preview (production-accurate)
```
