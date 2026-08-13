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
- ✅ `SellerVerificationScreen` — `/seller-verification` (name, phone, reason form)

### Home
- ✅ `HomeScreen` — `/home` (greeting, search, daily portion, categories, kingdom projects — Coming Soon)
- ✅ `DailyPortionScreen` — `/daily-portion` (real API data: today's published portion with fallback, bookmark, mark-as-read, saved reflection)
- ✅ `NotificationsScreen` — `/notifications` (real API data, realtime updates, New/Earlier sections, mark-all-read, relative timestamps)
- ✅ `ProfileScreen` — `/profile` (gradient avatar, badges, role-based visibility, pull-to-refresh, auto-refresh on foreground)
  - ✅ Pull-to-refresh
  - ✅ Auto-refresh on app foreground
  - ⬜ Avatar image upload (currently initials-only)
  - ✅ Seller verification CTA + pending/verified status
- ✅ `EditProfileScreen` — `/edit-profile`
  - ✅ Name, email, phone, location fields
  - ⬜ Avatar image picker & upload
  - ⬜ Phone/email verification badge
- ✅ `SettingsScreen` — `/settings`
  - ✅ Change Password (`/change-password` — real Supabase `updateUser` backend)
  - ✅ Language picker (`/language`)
  - ✅ Notification settings toggle (`/notification-settings`)
  - ✅ Buyer/Seller role toggle (`/buyer-seller-role` — real `updateUser` backend)
  - ✅ Trusted Member Status (`/trusted-member-status`), Contact Us, Send Feedback, About
  - ⬜ Dark mode toggle

### Marketplace
- ✅ `MarketplaceScreen` — `/marketplace` (filters, chips, property cards, FAB, real API data)
  - ✅ Category, location, type, seller, price, size filters
  - ✅ Save/unsave properties
  - ✅ Property detail screen with image gallery (full-screen PageView + dot indicators)
  - ✅ Image display from `property.images` (loading spinner + error fallback)
  - ✅ Pagination / infinite scroll (server-side `.range()`, 20/page)
  - ⬜ Search bar integration
  - ⬜ Sort options (price, date, location)
- ⬜ `SearchResultsScreen` — `/search-results`

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
- ✅ 6 migrations executed in Supabase
- ✅ RLS policies on all tables
- ✅ Auth trigger `handle_new_user()` auto-creates profile
- ⬜ Migration: `00007_storage_property_images.sql` — Create `property_images` storage bucket with RLS
- ⬜ Migration: `00008_storage_avatars.sql` — Create `avatars` storage bucket with RLS
- ⬜ Migration: `00009_storage_project_images.sql` — Create `project_images` storage bucket with RLS

### Storage
- ✅ `verification_documents` bucket (created in migration)
- ✅ `property_images` bucket (created in migration, RLS-protected)
- ✅ All image uploads go through Supabase Storage with user-scoped paths
- ✅ ImageKit private-key upload removed from the client (security — keys in app binaries are extractable)
- ⬜ `avatars` bucket (needs creation)
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
- ⬜ Avatar image upload (crop, resize, store in `avatars` bucket)
- ⬜ Phone/email verification badge
- ⬜ Dark mode toggle
- ⬜ Delete account flow

### Kingdom Projects
- ⬜ Project creation with image + goal + description
- ⬜ Project detail with progress bar, backers list
- ⬜ Donation flow (stripe/paystack integration?)
- ⬜ My projects dashboard
- ⬜ Project status lifecycle (pending → active → completed/cancelled)

### Reviews & Ratings
- ⬜ Review creation form (rating 1-5, comment)
- ⬜ Reviews list on property detail
- ⬜ Average rating calculation
- ⬜ Reviewer identity (verified buyer badge)

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
- ⬜ `SearchResultsScreen` — cross-entity search
- ⬜ Debounced API queries
- ⬜ Search history
- ⬜ Filters within search results

### Infrastructure & DX
- ✅ GitHub Actions keep-alive workflow
- ⬜ Error boundary / crash reporting (Sentry?)
- ⬜ Image caching (cached_network_image)
- ⬜ Offline support / local cache
- ⬜ CI/CD for Flutter builds
- ⬜ Deep linking / universal links
- ⬜ Analytics (Firebase?)

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
- ⬜ Migrations 00009–00012 pending execution in Supabase SQL Editor

---

## Technology Stack
- ✅ Flutter 3.19+ with Material 3
- ✅ Supabase Flutter ^2.5.0
- ✅ google_fonts ^6.1.0 (Inter)
- ✅ flutter_dotenv — environment variables
- ✅ file_picker — document/image uploads
- ✅ Supabase Storage buckets for all image uploads (`property_images`, RLS-protected)
- ✅ `http` ^1.2.0 — HTTP client for direct Supabase Storage uploads
- ✅ firebase_core + firebase_messaging — FCM push notifications (guarded)
- ✅ git ignored .env for security
- ✅ GitHub Actions keep-alive workflow
- ✅ App protection (root/jailbreak detection, screen protection)

## Models
- ✅ `UserProfile` — with `canSell`, `canBuy`, `isBoth`, `displayRole`, `firstName`
- ✅ `Property` — with `formattedPrice`, `fromMap`, `toMap`, `images` (List\<String\>)
- ✅ `KingdomProject` — with `progressPercent`, `fromMap`, `toMap`

## Security
- ✅ `AppProtection` — root/jailbreak detection, screen protection, debug detection
- ✅ RLS policies on all tables
- ✅ Profiles INSERT/UPDATE policies
- ✅ `.env` and `android/app/google-services.json` gitignored (Firebase keys never committed)
- ✅ No secret keys in the app binary (ImageKit private key removed)
- ✅ `flutter analyze` clean (0 issues incl. `use_build_context_synchronously` crash risks)

## Design
- ✅ `AppTheme` — full Serene Covenant palette (50+ color tokens), Inter typography
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

## Next Priority Order
1. ✅ **Property Images** — migration, secure Storage uploads, card, image display, detail screen, 8-image limit
2. ✅ **Property Management** — edit/delete/archive/reactivate, status badges, rejection reason, submit draft
3. ✅ **Notifications & Push** — realtime in-app, FCM push, admin notify, verification termination
4. 🔄 **Profile & Settings** — change password, role toggle, notification prefs, language picker done; ⬜ avatar upload, dark mode, phone/email verification badge
5. ✅ **Daily Portion** — real data (today's portion, read status, reflections, bookmarks)
6. ⬜ **Kingdom Projects** — full CRUD, donations
7. ⬜ **Reviews & Ratings**
8. ⬜ **Search** — cross-entity
9. ⬜ **Infrastructure** — error tracking, caching, CI/CD
