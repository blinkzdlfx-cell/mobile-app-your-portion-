
# Supabase Keep-Alive — Full Setup Guide

Prevents your free-tier Supabase project from being paused after 7 days of inactivity.

## How It Works

A GitHub Actions cron job runs **every Sunday at midnight (UTC)** and sends a lightweight SQL query (`SELECT id FROM profiles LIMIT 1`) to your Supabase REST API. This touches the database and resets the inactivity timer.

---

## Step-by-Step Setup

### Prerequisites

Before you start, have these ready:
- Your Supabase project is already created (from the Supabase dashboard)
- You have the project's **URL** and **anon key** (we'll fetch them below)
- You have a GitHub account

---

### Step 1: Get Your Supabase Credentials

1. Go to [supabase.com](https://supabase.com) and log in
2. Open **your project** from the dashboard
3. In the left sidebar, click **Project Settings** (gear icon)
4. Scroll down to **Configuration → API**
5. Under **Project API keys**, copy these two values:

   | Field | What it looks like |
   |-------|--------------------|
   | **Project URL** | `https://xxxxxxxxxxxxxx.supabase.co` |
   | **anon public** | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ...` |

   > Your `assets/.env` file already has these same values. You can copy from there too.

---

### Step 2: Create a GitHub Repository

If you haven't pushed this project to GitHub yet:

1. Go to [github.com/new](https://github.com/new)
2. Enter a repository name (e.g. `your-portion`)
3. Choose **Public** or **Private** (your choice)
4. Click **Create repository**
5. You'll land on a page with setup instructions — keep that tab open

Now, open a terminal in your project folder:

```bash
# 1. Initialize git (if not already done)
git init

# 2. Add all files
git add .

# 3. Commit
git commit -m "Initial commit"

# 4. Link to your GitHub repo (replace USERNAME and REPO-NAME)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# 5. Rename branch to main
git branch -M main

# 6. Push to GitHub
git push -u origin main
```

> If Git asks for authentication, use a [personal access token](https://github.com/settings/tokens) instead of your password.

---

### Step 3: Add Supabase Secrets to GitHub

Now we need to securely store your Supabase URL and anon key so the workflow can use them.

1. Go to **your GitHub repo** at `https://github.com/YOUR_USERNAME/YOUR_REPO_NAME`
2. Click the **Settings** tab (near the top right)
3. In the left sidebar, click **Secrets and variables → Actions**
4. Click the green **New repository secret** button

**Add the first secret:**

| Field | Value |
|-------|-------|
| Name | `SUPABASE_URL` |
| Secret | Paste your Project URL (e.g. `https://xxxxxxxxxxxxxx.supabase.co`) |

Click **Add secret**.

**Add the second secret:**

| Field | Value |
|-------|-------|
| Name | `SUPABASE_ANON_KEY` |
| Secret | Paste your anon public key (the long `eyJ...` string) |

Click **Add secret**.

You should now see both secrets listed under **Repository secrets**.

---

### Step 4: Verify the Workflow File

Check that the workflow file exists in your project:

```
your-portion/
  .github/
    workflows/
      supabase_keep_alive.yml    ← this one
```

If you pushed the repo after creating this file, it's already there. If not, make sure you've committed and pushed.

---

### Step 5: Enable GitHub Actions

GitHub Actions is enabled by default. To confirm:

1. Go to your repo on GitHub
2. Click the **Actions** tab (between Pull requests and Projects)
3. You should see **Supabase Keep Alive** listed in the left sidebar
4. If not, the workflow file may not be on the default branch — make sure you pushed to `main`

---

## Verification — Test It Now

Don't wait for the Sunday cron — trigger it manually.

### Manual Trigger

1. Go to your repo → **Actions** tab
2. In the left sidebar, click **Supabase Keep Alive**
3. You'll see a yellow banner: **This workflow has a workflow_dispatch event** — click the **Run workflow** button
4. A dropdown appears — leave `main` selected and click the green **Run workflow**
5. A new run appears in the list. Click on it to see the live logs

### Read the Logs

1. Inside the workflow run, expand the **Ping Supabase Database** step
2. You should see output like:

   ```
   Supabase responded with status: 200
   ```

   A `200` or `2xx` status means success. If you see `000` (no route to host), check your URL secret.

3. Check the **Log timestamp** step — it prints the ping time in UTC

> If the run fails, see **Troubleshooting** below.

---

## How to Confirm It's Working Long-Term

| What to check | Where to look |
|---------------|---------------|
| Next scheduled run | Actions tab → Supabase Keep Alive → the schedule shows on the workflow page |
| Run history | Actions tab — green checkmarks mean successful pings |
| Supabase project status | Supabase dashboard — your project shows **Active**, not **Paused** |

---

## Troubleshooting

### Workflow doesn't appear in Actions tab
- The `.github/workflows/supabase_keep_alive.yml` file must exist on the **default branch** (usually `main`)
- Make sure you committed and pushed: `git push origin main`

### Run fails with HTTP 401 or 403
- Your `SUPABASE_ANON_KEY` is incorrect. Go to repo Settings → Secrets → update it with the correct anon key from Supabase dashboard → Project Settings → API

### Run fails with HTTP 000 (no route to host)
- Your `SUPABASE_URL` is wrong or missing `https://`
- Check the URL ends with `.supabase.co` — no trailing slash needed

### "Resource not accessible by integration"
- Go to repo Settings → Actions → General → ensure **Workflow permissions** is set to **Read and write permissions**

### Need to change the schedule
- Edit the `cron` value in `.github/workflows/supabase_keep_alive.yml`
- Format: `'minute hour day-of-month month day-of-week'`
- Generate cron expressions at [crontab.guru](https://crontab.guru)
- The current schedule `0 0 * * 0` = every Sunday at midnight UTC

---

## Behind the Scenes

The workflow does exactly this when triggered:

```bash
curl -s -o /dev/null -w "%{http_code}" \
  "https://YOUR_PROJECT.supabase.co/rest/v1/profiles?select=id&limit=1" \
  -H "apikey: eyJhbGciOiJ..." \
  -H "Authorization: Bearer eyJhbGciOiJ..."
```

It runs `SELECT id FROM profiles LIMIT 1` via Supabase's REST API. This is:
- **Read-only** — no data is changed
- **Lightweight** — returns 1 row or empty set
- **Authenticated** — uses your anon key (same one your mobile app uses, safe for public use)
