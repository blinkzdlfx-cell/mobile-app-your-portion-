# Your Portion — Architecture

## High-Level Data Flow
```
UI (Screens)
    ↕ state via StatefulWidget
Business Logic (services/SupabaseService.dart)
    ↕ Supabase client
Database (Supabase PostgreSQL with RLS)
```

## App Initialization Flow
```
main()
  ├── WidgetsFlutterBinding.ensureInitialized()
  ├── dotenv.load()              # assets/.env
  ├── Supabase.initialize()      # url + publishableKey
  ├── SystemChrome.setPreferredOrientations()
  ├── SystemChrome.setSystemUIOverlayStyle()
  ├── AppProtection.validateAppIntegrity()  # release only
  └── runApp(MyApp)
```

## Navigation Map
```
SplashScreen
  → WelcomeScreen
  → LoginScreen ↔ SignupScreen ↔ ForgotPasswordScreen
  → ChooseRoleScreen
      ├── No session (unconfirmed email) → "Verify Your Email" → /login
      └── Has session → Buyer → /home
                      → Seller → /document-upload → /home
  → (BecomeTrustedMemberScreen)

HomeScreen (bottom nav: 0=Daily)
  ├── /search-results
  ├── /marketplace (bottom nav: 1=Market)
  │     ├── /search-results
  │     ├── /saved-properties
  │     └── /create-property (checks canSell; shows verification prompt if not verified)
  ├── /kingdom-projects (bottom nav: 2=Kingdom) — Coming Soon
  └── /profile (bottom nav: 3=Profile)
        ├── /edit-profile
        ├── /settings
        ├── /saved-properties
        ├── /my-properties (sellers only)
        ├── /bookmarked-portions
        └── /help-support
```

## Auth Flow Diagram
```
User → Signup (/signup)
  → Supabase.auth.signUp(email, password, data)
  → Profile created via trigger handle_new_user()
  → Navigate to /choose-role
  → No session (email not confirmed)
      → "Verify Your Email" screen → /login
  → Has session
      → Pick role (Buyer/Seller)
      → Role saved to auth.user_metadata + profiles.update()
      → Buyer → /home
      → Seller → /document-upload
          → Upload ID type + gov ID file + face image
          → Submit for admin review
          → Skip (verify later from profile)
          → /home

User → Seller Verification (from /profile)
  → /document-upload
  → Upload ID type + gov ID + face image
  → Admin approves → is_seller_verified = true

User → Create Property (/create-property)
  → Check canSell()
  → Not verified → "Verification Required" prompt → /profile
  → Verified → property listing form
```

## Role Decision Tree
```
UserProfile.role
  ├── 'buyer'  → canBuy=true, canSell=false
  ├── 'seller' → canBuy=true, canSell=(isSellerVerified)
  └── 'both'   → canBuy=true, canSell=(isSellerVerified)

canSell = isSellerVerified && (role == 'seller' || role == 'both')
```

## Widget Tree (HomeScreen example)
```
MaterialApp
  └── HomeScreen
        ├── SafeArea
        │     ├── Header (greeting + name + notifications icon)
        │     └── SingleChildScrollView
        │           ├── AnimatedContainer (search bar)
        │           ├── Today's Portion card
        │           ├── Marketplace section
        │           │     ├── "Browse" link
        │           │     └── Row of _CategoryCard × 4
        │           └── Kingdom Projects card
        └── BottomNavBar
              ├── _NavItem (Daily)
              ├── _NavItem (Market)
              ├── _NavItem (Kingdom)
              └── _NavItem (Profile)
```

## Admin Dashboard (Next.js 15 + Tailwind, separate web app)
```
admin-dashboard/
├── src/
│   ├── app/
│   │   ├── api/            # Route Handlers (no Express)
│   │   │   ├── auth/login/         → POST /api/auth/login
│   │   │   ├── dashboard/          → GET  /api/dashboard
│   │   │   ├── verification/       → CRUD for seller/trusted requests
│   │   │   ├── properties/         → CRUD for property listings
│   │   │   └── projects/           → CRUD for kingdom projects
│   │   ├── dashboard/page.tsx      — Stats grid, quick actions
│   │   ├── verification/page.tsx   — Filterable request list, approve/reject
│   │   ├── properties/page.tsx     — Property approval list
│   │   ├── projects/page.tsx       — Project approval list with progress bars
│   │   ├── page.tsx                — Login page
│   │   └── layout.tsx              — Root layout with Toast + Auth providers
│   └── lib/
│       ├── admin-layout.tsx        — Reusable sidebar + topbar
│       ├── auth-context.tsx        — React context for JWT auth state
│       ├── api-client.ts           — Typed fetch wrapper with JWT Bearer token
│       ├── api-utils.ts            — Server helpers (authGuard, responses)
│       ├── auth.ts                 — jose JWT create/verify helpers
│       ├── supabase.ts             — Supabase admin client (service_role)
│       └── toast.tsx               — Toast notification system
├── tailwind.config.ts         — Custom colors (primary, sage, cream), animations
├── next.config.js             — Next.js config
├── wrangler.toml              — Cloudflare Pages/Workers config
├── package.json               — next, react, @supabase/supabase-js, jose
├── .env.example / setup-env.mjs — Env setup
└── README.md                  — Full docs
```

**How it works:**
1. Next.js builds to static pages + Cloudflare Workers output
2. API routes run on Cloudflare Workers runtime (no Express, no Node.js server)
3. All database operations use `@supabase/supabase-js` with the **service role key** (bypasses RLS)
4. Admin authenticates via JWT (jose, HS256) — password compared against `ADMIN_PASSWORD_HASH` env var
5. Toast notifications replace browser `alert()` — success/error/info variants

**Deployment:** Build with `npm run build`, deploy with `npm run deploy`. Or connect to Cloudflare Pages via Git. See `docs/DEPLOY_ADMIN.md` for full instructions.

**API endpoints:**
| Endpoint | Purpose |
|----------|---------|
| `POST /api/auth/login` | Authenticate admin |
| `GET /api/dashboard` | Pending counts (seller, trusted, properties, projects) |
| `GET /api/verification/requests` | List verification requests (with type/status filters) |
| `POST /api/verification/approve` | Approve a request |
| `POST /api/verification/reject` | Reject with reason |
| `GET /api/properties/pending` | List pending properties |
| `POST /api/properties/approve` | Approve a property |
| `POST /api/properties/reject` | Reject with reason |
| `GET /api/projects/pending` | List pending projects |
| `POST /api/projects/approve` | Approve a project |
| `POST /api/projects/reject` | Reject with reason |

**Old Express version** is backed up at `admin-dashboard-express-backup/`.

## Database ER (Logical)
```
auth.users
    ↓ (trigger: on_auth_user_created)
profiles (id PK → auth.users)
    ├── properties (seller_id → profiles, category, price, location, ...)
    │     ├── saved_properties (user_id → profiles, property_id → properties)
    │     └── reviews (property_id → properties, reviewer_id → profiles)
    └── kingdom_projects (creator_id → profiles)
          └── project_donations (project_id → kingdom_projects, donor_id → profiles)
```
