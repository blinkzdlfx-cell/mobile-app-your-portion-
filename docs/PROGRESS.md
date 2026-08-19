# Your Portion — Progress Tracker

> **Workflow rule (since `ed52627`):** future edits go on a branch, get
> verified (analyze/test/apk), then merge to `main` only after confirmation.
> Full checklist: `docs/BRANCH_WORKFLOW.md`.

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
- ✅ `SellerVerificationScreen` — `/seller-verification` (name, phone, reason form)

### Home
- ✅ `HomeScreen` — `/home` (greeting, search, daily portion, categories, kingdom projects — Coming Soon)
- ✅ `DailyPortionScreen` — `/daily-portion` (real API data: today's published portion with fallback, bookmark, mark-as-read, saved reflection; accepts `initialPortionId` for deep-link from search)
- ✅ `NotificationsScreen` — `/notifications` (real API data, realtime updates, New/Earlier sections, mark-all-read, relative timestamps)
- ✅ `ProfileScreen` — `/profile` (gradient avatar, badges, role-based visibility, pull-to-refresh, auto-refresh on foreground)
  - ✅ Pull-to-refresh
  - ✅ Auto-refresh on app foreground
  - ✅ Avatar image display (cached, falls back to initials)
  - ✅ Email-verified indicator next to name
  - ✅ Seller verification CTA + pending/verified status
- ✅ `EditProfileScreen` — `/edit-profile`
  - ✅ Name, email, phone, location fields
  - ✅ Avatar image picker & upload (taptastic, Supabase Storage `avatars` bucket)
  - ✅ Email verification badge next to Edit Profile in settings
- ✅ `SettingsScreen` — `/settings`
  - ✅ Change Password (`/change-password` — real Supabase `updateUser` backend)
  - ✅ Language picker (`/language`)
  - ✅ Notification settings toggle (`/notification-settings`)
  - ✅ Buyer/Seller role toggle (`/buyer-seller-role` — real `updateUser` backend)
  - ✅ Trusted Member Status (`/trusted-member-status`), Contact Us, Send Feedback, About
  - ✅ Dark mode toggle (persisted, full dark palette)
  - ✅ Email verification status tile
  - ✅ Delete account (edge function + confirmation dialog)

### Marketplace
- ✅ `MarketplaceScreen` — `/marketplace` (filters, chips, property cards, FAB, real API data)
  - ✅ Category, location, type, seller, price, size filters
  - ✅ Save/unsave properties
  - ✅ Property detail screen with image gallery (full-screen PageView + dot indicators)
  - ✅ Image display from `property.images` (cached, loading + error fallback)
  - ✅ Pagination / infinite scroll (server-side `.range()`, 20/page)
  - ✅ Search bar (home screen) → `/search-results` with query argument
  - ✅ Sort options (Newest, Price low→high, Price high→low — server-side `.order()`)
- ✅ `SearchResultsScreen` — `/search-results` (debounced cross-entity search, recent searches, filter chips, sectioned results)

### Properties
- ✅ `SavedPropertiesScreen` — `/saved-properties` (real API data)
  - ⬜ Image display in saved property cards
- ✅ `CreatePropertyScreen` — `/create-property` (checks canSell, verification prompt if not verified, edit mode)
  - ✅ Image picker (FileType.image — any format)
  - ✅ Upload to Supabase Storage `property_images` bucket (RLS-protected; private-key ImageKit uploads removed for security)
  - ✅ 8-image limit with live counter
  - ✅ Image preview thumbnails with X remove
  - ✅ Save Draft + Submit Property
  - ✅ Edit mode (pre-fills from existing property, resubmits)
- ✅ `MyPropertiesScreen` — `/my-properties` (hidden for buyers)
  - ✅ Edit/delete property from list
  - ✅ Status badge (colored chips: draft/pending/approved/rejected/archived)
  - ✅ Rejection reason banner
  - ✅ Contextual actions per status (edit, submit, archive, reactivate, delete)
  - ✅ Delete confirmation dialog
- ✅ `PropertyDetailScreen` — `/property-detail` (PageView image gallery, dot indicators, status badges, specs table, contact seller)
  - ✅ Reviews section (average rating, verified-reviewer names, empty state)
  - ✅ Review sheet — star rating + comment, submit/edit/delete

### Kingdom Projects
- ✅ `KingdomProjectsScreen` — `/kingdom-projects` (real API data, status filter chips, detail bottom sheet, create FAB with canSell gating)
- 🔄 `CreateKingdomProjectScreen` — `/create-kingdom-project`
  - ⬜ Image upload for project
  - ⬜ Donation integration
- ⬜ `ProjectDetailScreen` — `/project-detail` with donation form, progress, backers

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

### SupabaseService
- ✅ Server-side filtered queries everywhere (`.eq()`, `.inFilter()`, `.order()` — no more fetch-all-then-filter)
- ✅ Paginated `getProperties` (page/pageSize) + `getPropertiesByIds` for saved listings
- ✅ `getProperties` sort (`sortBy`: newest / price_asc / price_desc)
- ✅ Search (`searchProperties` / `searchProjects` / `searchPortions` — ilike title)
- ✅ Reviews CRUD (`getReviews`, `getMyReview`, `addReview`, `updateReview`, `deleteReview`)
- ✅ Avatar upload (`uploadAvatar` → `avatars` storage bucket, RLS-protected)
- ✅ Account (`isEmailVerified`, `deleteAccount` via edge function)
- ✅ Profile CRUD (`getCurrentProfile`, `updateProfile`)
- ✅ Property CRUD (`getProperties`, `getMyProperties`, `createProperty`, `updateProperty`, `deleteProperty`)
  - ✅ `getProperties` filters to `status == 'approved'` for marketplace
  - ✅ `saveDraft`, `updateDraft`, `archiveProperty`, `reactivateProperty`
- ✅ Saved Properties (`getSavedPropertyIds`, `saveProperty`, `unsaveProperty`)
- ✅ Kingdom Projects (`getProjects`, `getMyProjects`, `createProject`)
- ✅ Bookmarked Portions (`getBookmarkedPortions`, `isPortionBookmarked`, `bookmarkPortion`, `removeBookmarkedPortion`)
- ✅ Verification Requests (`submitVerificationRequest`, `getPendingRequest`)
- ✅ File upload (`uploadFile`, `uploadVerificationDocument`, `uploadFaceImage`, `uploadPropertyImage`)
- ✅ Role helpers (`canSell`, `isAdmin`)
- ✅ Admin methods (get/approve/reject for verification, properties, projects)

### Database
- ✅ Migrations 00001–00012 executed in Supabase
- ✅ Migration `00013_account_and_reviews.sql` — `avatars` bucket + RLS, reviews DELETE policy, profiles self-delete policy (⚠️ pending execution in SQL Editor)
- ✅ RLS policies on all tables
- ✅ Auth trigger `handle_new_user()` auto-creates profile
- ⬜ Edge function `delete-account` — deploy with `supabase functions deploy delete-account` (needs `SUPABASE_SERVICE_ROLE_KEY` + "Allow users to delete their account" setting)

### Storage
- ✅ `verification_documents` bucket (created in migration)
- ✅ `property_images` bucket (created in migration, RLS-protected)
- ✅ `avatars` bucket (migration `00013`, ⚠️ pending execution)
- ✅ All image uploads go through Supabase Storage with user-scoped paths
- ✅ ImageKit private-key upload removed from the client (security — keys in app binaries are extractable)
- ⬜ `project_images` bucket (needs creation)

---

## Key Implementation Updates

### Seller Verification Flow (end-to-end) — ✅ Complete
- User submits request via `SellerVerificationScreen`
- User uploads docs via `DocumentUploadScreen`
- Admin reviews via web dashboard
- Admin approves → `profiles.is_seller_verified = true`
- App reflects changes via WidgetsBindingObserver + pull-to-refresh
- ✅ Verification status card (`VerificationStatusCard` widget) on profile/settings — pending/approved/rejected/terminated states with admin reason + re-apply CTA
- ✅ Admin can terminate verification (`/api/verification/terminate`) — revokes `is_seller_verified` / `is_trusted_member`, records reason, notifies user

### Notifications & Push — ✅ Complete
- ✅ `notifications` table + realtime publication (migration `00010`)
- ✅ `device_tokens` table for FCM (migration `00011`)
- ✅ `NotificationBell` widget — live unread badge via Postgres realtime
- ✅ `NotificationsScreen` — realtime inserts, New/Earlier grouping, mark-all-read
- ✅ `PushNotificationService` — Firebase FCM (guarded: app runs fine without Firebase config), token sync to `device_tokens` on login/refresh, unregister on logout
- ✅ Admin `notifyUser()` helper — in-app insert + email (SMTP) + push (FCM HTTP v1 with OAuth2, legacy fallback)
- ✅ Notifications sent on verification approve/reject/terminate
- ✅ Admin storage proxy `/api/storage/[...path]` + `DocumentViewer` component — admins can view uploaded ID/face documents

### Property Images — ✅ Complete (secured)
- ✅ Uploads via Supabase Storage `property_images` bucket (RLS-protected)
- ✅ ImageKit private-key auth removed from the client — previously extractable from the app binary
- ✅ 8-image limit per property post

### Property Management (Seller)
- ✅ Edit property (pre-fill form from `existingProperty`, update images, resubmit)
- ✅ Delete property with confirmation dialog
- ✅ Status badge (draft/pending/approved/rejected/archived) with colored chip
- ✅ Rejection reason display
- ✅ Submit draft for review
- ✅ Archive / Reactivate property
- ⬜ Analytics (views, saves count)

### Profile & Settings
- ✅ Change Password (Supabase `updateUser`)
- ✅ Buyer/Seller role toggle (Supabase `updateUser`)
- ✅ Notification preferences screen
- ✅ Language picker screen
- ✅ Avatar image upload (pick → `avatars` bucket → cached preview)
- ✅ Email verification badge
- ✅ Dark mode toggle (persisted) — full dark palette via brightness-aware `AppTheme`
- ✅ Delete account flow (edge function, confirmation dialog)

### Kingdom Projects
- ⬜ Project creation with image + goal + description
- ⬜ Project detail with progress bar, backers list
- ⬜ Donation flow (stripe/paystack integration?)
- ⬜ My projects dashboard
- ⬜ Project status lifecycle (pending → active → completed/cancelled)

### Reviews & Ratings
- ✅ Review creation form (rating 1-5 stars, comment)
- ✅ Reviews list on property detail (with reviewer join `reviewer:profiles`)
- ✅ Average rating calculation
- ✅ Reviewer identity (seller-verified badge)
- ✅ Edit / delete own review

### Daily Portion — ✅ Complete
- ✅ Fetch from `daily_portions` table (published only, newest first)
- ✅ Today's portion logic (`getTodayPortion` — date match with latest-published fallback)
- ✅ Read status tracking (`portion_reads` table, migration `00012`)
- ✅ Reflection saving per user per portion (`portion_reflections` table, migration `00012`)
- ✅ Bookmark/read status tracking with real portion IDs
- ✅ Home screen "Today's Portion" card shows real title, scripture reference, and content snippet
- ✅ `DailyPortion` model with paragraph rendering (`paragraphs`)
- ⬜ Rich text / links inside portion content

### Notifications
- ✅ Fetch from `notifications` table
- ✅ Read/unread state (mark-all-read)
- ✅ Push notification integration (FCM, guarded)
- ✅ In-app notification badge (realtime)

### Search
- ✅ `SearchResultsScreen` — cross-entity search (Daily Portions, Properties, Kingdom Projects)
- ✅ Debounced API queries (400 ms)
- ✅ Search history (SharedPreferences, max 5, tappable)
- ✅ Filters within search results (all/portions/properties/projects)

### Infrastructure & DX
- ✅ GitHub Actions keep-alive workflow (⚠️ to be replaced by Cloudflare cron)
- ✅ CI gate (`.github/workflows/ci.yml`) — `flutter analyze` + `flutter test` + debug APK build on push/PR
- ✅ Sentry crash reporting (initialized when `--dart-define=SENTRY_DSN=...` is provided)
- ✅ Image caching (cached_network_image across property card/detail/gallery/avatars)
- ✅ Test suite (18 tests: all 5 model unit-test groups + app-boot smoke test)
- ✅ Debug APK build green (Flutter 3.44.0, Gradle 8.14, AGP 8.13.0, Kotlin 2.3.20, JDK 17, NDK 28.2.13676358) — see "Android Toolchain" below
- ⬜ Replace GitHub keep-alive with Cloudflare cron triggers (see Backend Plan below)
- ⬜ Push notification worker on Cloudflare Workers (scheduled sends + keep-alive; admin `notifyUser()` already covers manual admin sends)
- ⬜ Offline support / local cache
- ⬜ Deep linking / universal links
- ⬜ Analytics (Firebase?)

### Android Toolchain — ✅ Debug build green (2026-08-19)
- Root cause of the long build saga: repo scaffolded on bleeding-edge AGP 9.0.1 + Kotlin 2.3.20 + Gradle 9.1 while plugins (`sentry_flutter`, `file_picker`, `jni`) still apply classic KGP / old compileSdk — per Flutter 3.44 docs, AGP 9 requires plugins migrated to built-in Kotlin (not the case yet).
- Fixed by pinning the documented known-good matrix: **Gradle 8.14 / AGP 8.13.0 / Kotlin 2.3.20 / JDK 17** (`android/settings.gradle.kts`, wrapper) + `android/build.gradle.kts` overrides:
  - `languageVersion = KOTLIN_2_0` on `sentry_flutter`/`package_info_plus` KotlinCompile (they hard-code 1.6, rejected by modern KGP)
  - `ndkVersion = "28.2.13676358"` + `compileSdk = 36` on every `com.android.library` module, set in `subprojects { afterEvaluate { } }` so it wins over module-declared values (fixes `:jni` (jni-0.14.1) compiling against android-31 → AAR metadata check failures)
- `android/gradle.properties`: added `org.gradle.internal.repository.max.retries=10` + backoff (this machine's connection to dl.google.com dropped mid-download twice — flaky network, fixed by retries)
- Package bumps (uncommitted): `sentry_flutter` ^9.0.0, `file_picker` ^10.0.0
- Relevant warnings (benign, future work): "Unsupported Kotlin plugin version" (Flutter tooling embedded-kotlin vs KGP 2.2.20 in buildscript — `:gradle` build only), KGP-applying plugins warning (upgrade path: sentry/package_info_plus → built-in Kotlin once available)

---

> **Note:** The old Express-based admin dashboard is backed up at `admin-dashboard-express-backup/`.

## Admin Dashboard (Next.js + Tailwind) — ✅ Complete
### Frontend
- ✅ Next.js 15 App Router with TypeScript
- ✅ Tailwind CSS — custom color tokens, animations
- ✅ `src/app/page.tsx` — Login page (gradient background)
- ✅ `src/app/dashboard/page.tsx` — Stats grid (4 cards), quick actions
- ✅ `src/app/verification/page.tsx` — Filterable request list, approve/reject/terminate modal, document viewer
- ✅ `src/app/properties/page.tsx` — Property approval list with reject modal
- ✅ `src/app/projects/page.tsx` — Project approval list with progress bars
- ✅ `src/components/document-viewer.tsx` — Modal viewer for uploaded verification documents
- ✅ `src/lib/notifications.ts` — `notifyUser()` (in-app + email + FCM push) with cached OAuth2 token
- ✅ `src/lib/admin-layout.tsx` — Sidebar nav + top bar + logout modal + mobile hamburger
- ✅ `src/lib/auth-context.tsx` — React context for JWT auth
- ✅ `src/lib/api-client.ts` — Typed fetch wrapper with JWT Bearer
- ✅ `src/lib/toast.tsx` — Toast notification system

### Backend (13 API routes, no Express)
- ✅ Auth: POST `/api/auth/login`
- ✅ Dashboard: GET `/api/dashboard`
- ✅ Verification: GET list, POST approve, POST reject, POST terminate
- ✅ Storage: GET `/api/storage/[...path]` (document viewing proxy)
- ✅ Properties: GET pending, POST approve, POST reject
- ✅ Projects: GET pending, POST approve, POST reject

### Deployment
- ✅ `wrangler.toml` — Cloudflare Workers/Pages
- ✅ `setup-env.mjs` — Interactive .env generator
- ✅ `.env.example` — Environment template
- ✅ `README.md` — Full docs

---

## Database & Infrastructure
- ✅ Migration: `00001_seller_buyer_schema.sql` (6 tables, RLS, trigger)
- ✅ Migration: `00002_bookmarked_portions.sql`
- ✅ Migration: `00003_verification_requests.sql`
- ✅ Migration: `00004_add_id_document_url.sql`
- ✅ Migration: `00005_add_id_type_and_face_image.sql`
- ✅ Migration: `00006_add_profiles_insert_policy.sql`
- ✅ Executed in Supabase project
- ✅ Migration: `00007_storage_property_images.sql` — `property_images` storage bucket + RLS
- ✅ Migration: `00008_property_lifecycle.sql` — status CHECK constraint (`draft`/`pending`/`approved`/`rejected`/`archived`), RLS SELECT policy, `rejection_reason` column
- ✅ Migration: `00009_verification_setup.sql` — verification request columns + storage bucket (idempotent)
- ✅ Migration: `00010_notifications_and_termination.sql` — `notifications` table + realtime, termination columns (idempotent)
- ✅ Migration: `00011_device_tokens.sql` — `device_tokens` table for FCM push (idempotent)
- ✅ Migration: `00012_portion_reads.sql` — `portion_reads` (read status) + `portion_reflections` tables (idempotent)
- ✅ Migration: `00013_account_and_reviews.sql` — `avatars` bucket + RLS, `property_reviews` DELETE policy, profiles self-delete policy (⚠️ pending execution in SQL Editor)
- ✅ Migration: `00014_daily_portions_queue.sql` — portions write-ahead queue (⚠️ pending execution in SQL Editor)
- ✅ Migration: `00015_push_worker.sql` — `push_logs` + `claim_oldest_portion()` RPC (⚠️ pending execution in SQL Editor)
- ⬜ Deploy edge function `delete-account` (needs `SUPABASE_SERVICE_ROLE_KEY`)

---

## Technology Stack
- ✅ Flutter 3.19+ with Material 3
- ✅ Supabase Flutter ^2.5.0
- ✅ google_fonts ^6.1.0 (Inter)
- ✅ flutter_dotenv — environment variables
- ✅ file_picker — document/image uploads
- ✅ cached_network_image — image caching (property images, avatars)
- ✅ shared_preferences — theme mode + search history persistence
- ✅ sentry_flutter — crash reporting (opt-in via `SENTRY_DSN` dart-define)
- ✅ Supabase Storage buckets for all image uploads (`property_images`, `avatars`, RLS-protected)
- ✅ `http` ^1.2.0 — HTTP client for direct Supabase Storage uploads
- ✅ firebase_core + firebase_messaging — FCM push notifications (guarded)
- ✅ git ignored .env for security
- ✅ GitHub Actions keep-alive workflow + CI gate (analyze/test/apk)
- ✅ App protection (root/jailbreak detection, screen protection)

## Models
- ✅ `UserProfile` — with `canSell`, `canBuy`, `isBoth`, `displayRole`, `firstName`
- ✅ `Property` — with `formattedPrice`, `fromMap`, `toMap`, `images` (List\<String\>)
- ✅ `KingdomProject` — with `progressPercent`, `fromMap`, `toMap`
- ✅ `DailyPortion` — with `paragraphs`
- ✅ `PropertyReview` — with reviewer join (`reviewer:profiles`)

## Security
- ✅ `AppProtection` — root/jailbreak detection, screen protection, debug detection
- ✅ RLS policies on all tables
- ✅ Profiles INSERT/UPDATE policies
- ✅ `.env` and `android/app/google-services.json` gitignored (Firebase keys never committed)
- ✅ No secret keys in the app binary (ImageKit private key removed)
- ✅ `flutter analyze` clean (0 issues incl. `use_build_context_synchronously` crash risks)

## Design
- ✅ `AppTheme` — full Serene Covenant palette (50+ color tokens), Inter typography, light + dark palettes
- ✅ `BottomNavBar` — reusable with Daily, Market, Kingdom, Profile tabs
- ✅ Profile card — gradient avatar, compact badges, professional layout

---

## Setup After Clone

```bash
git clone <repo-url> your-portion
cd your-portion

# Flutter app
flutter pub get
cp assets/.env.example assets/.env   # fill in your real Supabase keys

# Admin dashboard
cd admin-dashboard
cp .env.example .env                 # fill in real keys
npm install
cd ..
```

---

## Deferred Tasks (documented, NOT started)

Feature gaps (non-Kingdom-Projects):
- ⬜ Saved-property cards: image thumbnail display (`SavedPropertiesScreen`)
- ⬜ Learning Library: real articles/content + API (currently static placeholder cards)
- ⬜ Daily Portion: rich text / links inside portion content
- ⬜ Property analytics (view/save counts) on My Properties

Infrastructure:
- ⬜ Offline support / local cache
- ⬜ Deep linking / universal links
- ⬜ App analytics (Firebase or similar)

Deploy ops (needed for shipped features):
- ⬜ Run migration `00013_account_and_reviews.sql` in Supabase SQL Editor (avatars bucket + RLS, reviews DELETE policy, profiles self-delete)
- ⬜ Deploy edge function: `supabase functions deploy delete-account` (needs `SUPABASE_SERVICE_ROLE_KEY`; enable "Allow users to delete their account" in Auth settings)
- ⬜ Replace GitHub keep-alive action with Cloudflare cron triggers (push-worker built — deploy + delete workflows; see Backend Plan)

---

## Backend Plan (Push Notifications & Keep-Alive)

Direction agreed: consolidate on Cloudflare — keep GitHub Actions for CI only, move keep-alive + scheduled push to Cloudflare cron triggers/Workers, keep the whole backend easy to manage (single Worker surface, same account as the existing admin dashboard).

**Push delivery decision: Direct FCM via Cloudflare Worker (Appwrite Messaging evaluated and rejected).**
Why: volume is tiny (1 scheduled push/day + admin-triggered sends); FCM HTTP v1 send already works in the admin dashboard (same pattern to reuse); tokens already live in `device_tokens` (single source of truth); Appwrite would add a second backend platform (SDK in app, API keys, dashboard, free-tier limits) for no real gain at this scale. Delivery states go to a `push_logs` table instead.

Daily portion flow (agreed):
- Admin dashboard gets a Daily Portions section: two tabs — Posted / Unposted (write-ahead pool)
- Unposted = `is_published = false`, `publish_date = NULL`; Posted = cron claims oldest unposted, sets `publish_date = today`
- Cloudflare cron (single trigger, 6am) does BOTH: posts one portion per day (idempotent) AND keeps Supabase awake (free tier pauses only after 7 days of zero requests — a daily DB-touching job is a 7x safety margin; the GitHub keep-alive workflow gets deleted once live)
- AI writer (later): fills the unposted pool through the same admin API; cron unchanged

Implementation order:
- ✅ Migration `00014_daily_portions_queue.sql` — `publish_date` default → NULL (drafts must not look published-today), unique partial index on `publish_date` (idempotency guard) — ⚠️ pending SQL Editor run
- ✅ Admin dashboard: Daily Portions section — API routes (`GET/POST /api/portions`, `PATCH/DELETE /api/portions/[id]`) + UI (`/portions`: Unposted/Posted tabs, write-ahead form, edit inline, publish-now, unpost, delete)
- ✅ Migration `00015_push_worker.sql` — `push_logs` delivery table + `claim_oldest_portion()` RPC (atomic, idempotent, service-role only) — ⚠️ pending SQL Editor run
- ✅ Cloudflare Worker `push-worker/` — written, typechecked, builds (⚠️ needs `npm run deploy` + `wrangler secret put SUPABASE_SERVICE_ROLE_KEY` / `FCM_SERVICE_ACCOUNT`; 6am UTC cron posts one portion per day → FCM v1 push to `device_tokens` → stale-token pruning → `push_logs`; `/run` manual trigger; keep-alive comes free with the same job)
- ⬜ Delete GitHub keep-alive workflows once the push-worker cron has run once (`.github/workflows/supabase-keep-alive.yml` + `supabase_keep_alive.yml`)
- ⬜ AI portion writer (later): fills the unposted pool through the same admin API; cron unchanged
- ⬜ Appwrite: NOT planned — superseded by the direct-FCM decision above

---

## Next Priority Order
1. ✅ **Property Images** — migration, secure Storage uploads, card, image display, detail screen, 8-image limit
2. ✅ **Property Management** — edit/delete/archive/reactivate, status badges, rejection reason, submit draft
3. ✅ **Notifications & Push (in-app)** — realtime in-app, FCM push from admin, verification termination
4. ✅ **Profile & Settings** — avatar upload, dark mode, email verification badge, delete account (edge function to deploy)
5. ✅ **Daily Portion** — real data (today's portion, read status, reflections, bookmarks)
6. ✅ **Search** — cross-entity, debounced, history, filters
7. ✅ **Reviews & Ratings** — form, list, average, edit/delete
8. ✅ **Infrastructure** — Sentry (opt-in), image caching, CI gate, 18 tests, dark mode
9. ⬜ **Deferred tasks** — see "Deferred Tasks" above (small feature gaps, infra, deploy ops, backend plan)
10. ⬜ **Kingdom Projects** — full CRUD (image upload), donations, project detail — LAST
