# Deploying the Admin Dashboard

The admin dashboard is a Node.js/Express web app (not a Flutter screen). It serves both the admin UI (HTML/CSS/JS) and the REST API from a single server.

## Prerequisites

1. **Supabase project** with all 6 migration SQL files executed
2. **GitHub repository** with the code pushed
3. **Node.js 18+** installed locally (for generating secrets)

## Required Environment Variables

| Variable | Description | How to generate |
|----------|-------------|-----------------|
| `SUPABASE_URL` | Your Supabase project URL | Supabase dashboard → Settings → API |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key (bypasses RLS) | Supabase dashboard → Settings → API |
| `ADMIN_USERNAME` | Admin login username (e.g., `admin`) | Choose any |
| `ADMIN_PASSWORD_HASH` | bcrypt hash of the admin password | `node -e "require('bcryptjs').hash('your-password',10).then(console.log)"` |
| `JWT_SECRET` | Random string for signing JWT tokens | `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"` |

## Option 1: Render (Recommended — Free Tier)

1. Go to [dashboard.render.com](https://dashboard.render.com)
2. Click **New +** → **Web Service**
3. Connect your GitHub repository
4. Configure:
   - **Name**: `your-portion-admin` (or any name)
   - **Root Directory**: `admin-dashboard/server`
   - **Runtime**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free
5. Click **Advanced** and add all 5 environment variables from the table above
6. Click **Create Web Service**
7. Render will deploy and give you a URL like `https://your-portion-admin.onrender.com`
8. Open that URL in your browser — the admin login page appears

## Option 2: Railway

1. Go to [railway.app](https://railway.app)
2. Click **New Project** → **Deploy from GitHub repo**
3. Select your repository
4. Go to **Settings** → **Root Directory**: `admin-dashboard/server`
5. Go to **Variables** and add all 5 environment variables
6. Railway auto-detects Node.js and runs `npm start`
7. Open the generated URL

## Option 3: Fly.io (More Control)

1. Create `admin-dashboard/server/Dockerfile`:

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD ["node", "index.js"]
```

2. Deploy:
```sh
cd admin-dashboard/server
fly launch
fly secrets set SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... ADMIN_USERNAME=... ADMIN_PASSWORD_HASH=... JWT_SECRET=...
fly deploy
```

## Verifying the Deployment

1. Open the deployment URL in a browser
2. You should see the **Admin Login** page (green gradient background, centered login box)
3. Log in with the admin username and password you configured
4. The dashboard shows pending counts (all zeros if no data yet)
5. Test: `GET <your-url>/api/admin/health` should return `{ "status": "ok", "timestamp": "..." }`

## Important Notes

- The frontend (`api.js`) automatically uses `window.location.origin` as the API base — **no code changes needed** for different domains.
- The server binds to `0.0.0.0` and trusts the proxy — works behind Render/Railway's infrastructure.
- All 6 migration SQL files in `supabase/migrations/` **must be executed** in your Supabase SQL editor before the dashboard will show any data.
- The service role key is powerful — it bypasses all RLS policies. Keep it secret.
- To update the admin password later, generate a new bcrypt hash and update the `ADMIN_PASSWORD_HASH` env var, then redeploy.
