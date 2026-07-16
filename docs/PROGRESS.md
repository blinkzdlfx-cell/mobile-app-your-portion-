# Your Portion — Progress Tracker

## Legend
- ✅ Complete
- 🔄 In Progress
- ⬜ Not Started
- ❌ Blocked

---

## Screens

### Auth & Onboarding
- ✅ `SplashScreen` — `/splash`
- ✅ `OnboardingScreen` — `/onboarding` (3-page carousel)
- ✅ `WelcomeScreen` — `/welcome`
- ✅ `LoginScreen` — `/login` (email/password + Google + Apple, user-friendly error messages)
- ✅ `SignupScreen` — `/signup` (email/password + Google + Apple)
- ✅ `ForgotPasswordScreen` — `/forgot-password`
- ✅ `ChooseRoleScreen` — `/choose-role` (buyer/seller, detects unconfirmed email, shows verification prompt)
- ✅ `DocumentUploadScreen` — `/document-upload` (ID type selector + gov ID file + face image upload)
- ✅ `BecomeTrustedMemberScreen` — `/become-trusted-member`

### Home
- ✅ `HomeScreen` — `/home` (greeting, search, daily portion, categories, kingdom projects — Coming Soon)
- 🔄 `DailyPortionScreen` — `/daily-portion` (UI exists, real data integration needed)
- 🔄 `NotificationsScreen` — `/notifications`
- ✅ `ProfileScreen` — `/profile` (gradient avatar, professional card, badges, role-based visibility)
- ✅ `EditProfileScreen` — `/edit-profile`
- ✅ `SettingsScreen` — `/settings`

### Marketplace
- ✅ `MarketplaceScreen` — `/marketplace` (filters, chips, property cards, always-visible + FAB, real API data)
- ⬜ `SearchResultsScreen` — `/search-results`

### Properties
- ✅ `SavedPropertiesScreen` — `/saved-properties` (real API data)
- ✅ `CreatePropertyScreen` — `/create-property` (checks canSell, shows verification prompt if not verified)
- ✅ `MyPropertiesScreen` — `/my-properties` (hidden for buyers)

### Kingdom Projects
- ✅ `KingdomProjectsScreen` — `/kingdom-projects` (Coming Soon placeholder)
- 🔄 `CreateKingdomProjectScreen` — `/create-kingdom-project`

### Library
- 🔄 `LearningLibraryScreen` — `/learning-library`

### Utility
- ✅ `LoadingScreen` — `/loading`
- ✅ `OfflineScreen` — `/offline`
- ✅ `EmptyStateScreen` — `/empty-state`
- ✅ `SuccessScreen` — `/success`
- ✅ `HelpSupportScreen` — `/help-support`

---

## Services & Data Layer
- ✅ `SupabaseService` — all CRUD methods (profile, properties, saved, projects, bookmarks, verification)
- ✅ `uploadFile()` — generic file upload to any bucket/path
- ✅ `uploadFaceImage()` — face image upload for seller verification
- ✅ Supabase initialization in `main.dart`
- ✅ Real API data in marketplace, saved properties, my properties
- ⬜ Real API data in daily portion
- ⬜ Upload/display property images
- ⬜ Review creation & display
- ⬜ Project donation flow

---

## Key Implementation Updates

### Seller Verification Flow
- ID type selection (NIN / Voter Card / International Passport)
- Government ID file upload
- Face image upload for identity matching
- Admin approves/rejects via dashboard
- Skip option — complete later from profile

### Marketplace FAB
- Always shows **+** icon (no locking, no "Become a Seller" CTA)
- Everyone can browse freely
- Verification check moved to `CreatePropertyScreen`

### CreatePropertyScreen
- Checks `canSell()` on entry
- Not verified → shows "Verification Required" prompt with "Go to Profile to Verify" button
- Verified → shows property listing form

### ChooseRoleScreen
- Detects missing session (unconfirmed email)
- Shows "Verify Your Email" screen with "Go to Sign In" when no session
- Clear user-friendly error messages for all failure modes

### ProfileScreen
- Gradient avatar header instead of flat color
- Professional card layout with compact badges row
- "My Properties" hidden for buyers
- Seller verification CTA for unverified sellers

### Error Messages
- Signup: specific messages for duplicate email, weak password
- Login: specific messages for wrong credentials, unconfirmed email, rate limits
- Role save: detects expired session, RLS errors
- Document upload: detects connection issues, session expiry

---

## Admin Dashboard (Standalone Web App)
- ✅ `admin-dashboard/index.html` — SPA with 4 tabs
- ✅ `admin-dashboard/styles.css` — Login, cards, modals, toasts styling
- ✅ `admin-dashboard/scripts/api.js` — API client
- ✅ `admin-dashboard/scripts/app.js` — SPA logic
- ✅ `admin-dashboard/server/index.js` — Express server (port 3000)
- ✅ `admin-dashboard/server/setup.js` — Interactive .env generator
- ✅ Server starts gracefully without Supabase configured
- ✅ Login page renders with proper styling
- ✅ All 11 API endpoints implemented (login, dashboard, verification CRUD, property CRUD, project CRUD)
- ✅ Logout confirmation dialog

## Database & Infrastructure
- ✅ Migration: `00001_seller_buyer_schema.sql` (6 tables, RLS, trigger)
- ✅ Migration: `00002_bookmarked_portions.sql`
- ✅ Migration: `00003_verification_requests.sql`
- ✅ Migration: `00004_add_id_document_url.sql`
- ✅ Migration: `00005_add_id_type_and_face_image.sql`
- ✅ Migration: `00006_add_profiles_insert_policy.sql`
- ⬜ Executed in Supabase project (requires manual SQL run)

---

## Known Gaps
- `SearchResultsScreen` — shell exists but no content
- `DailyPortionScreen` — no real data fetching
- `NotificationsScreen` — no real data
- Property images — placeholder only (no asset URL or upload)
- Project donation flow — not built
- Review system — not built
- No error boundary / crash reporting
- No image caching or lazy loading
- No dark mode
- No localization / i18n

---

## High-Priority Next Steps
1. **Execute all Supabase Migrations** — Run SQL in Supabase dashboard (6 migration files)
2. **Property Images** — Add image upload and display capabilities
3. **Project Donations** — Implement donation flow
4. **Review System** — Implement review creation and display
5. **Daily Portion** — Fetch real data from `daily_portions` table
6. **Notifications** — Replace mock data with real notifications
7. **Search Results** — Implement cross-entity search

---

## Technology Stack
- ✅ Flutter 3.19+ with Material 3
- ✅ Supabase Flutter ^2.5.0
- ✅ google_fonts ^6.1.0 (Inter)
- ✅ flutter_dotenv — environment variables
- ✅ file_picker — document/image uploads
- ✅ git ignored .env for security
- ✅ GitHub Actions keep-alive workflow
- ✅ App protection (root/jailbreak detection, screen protection)

## Models
- ✅ `UserProfile` — with `canSell`, `canBuy`, `isBoth`, `displayRole`, `firstName`
- ✅ `Property` — with `formattedPrice`, `fromMap`, `toMap`
- ✅ `KingdomProject` — with `progressPercent`, `fromMap`, `toMap`

## Security
- ✅ `AppProtection` — root/jailbreak detection, screen protection, debug detection
- ✅ RLS policies on all tables
- ✅ Profiles INSERT/UPDATE policies
- ✅ `.env` gitignored

## Design
- ✅ `AppTheme` — full Serene Covenant palette (50+ color tokens), Inter typography, input/button themes
- ✅ `BottomNavBar` — reusable with Daily, Market, Kingdom, Profile tabs
- ✅ Profile card — gradient avatar, compact badges, professional layout
