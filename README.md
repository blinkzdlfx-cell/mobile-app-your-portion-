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
cd admin-dashboard/server
npm install
npm run setup    # enter Supabase URL, service role key, admin password
npm start        # → http://localhost:3000
```

The admin dashboard is a separate web app — not a Flutter screen. See `docs/ARCHITECTURE.md` for full details.
