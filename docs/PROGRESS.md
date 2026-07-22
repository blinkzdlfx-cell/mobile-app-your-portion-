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
- 🔄 `DailyPortionScreen` — `/daily-portion` (UI exists, real data integration needed)
- 🔄 `NotificationsScreen` — `/notifications`
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
  - ✅ Basic structure (Account, Preferences, Support, About, Logout)
  - ⬜ Change Password (UI exists, no backend)
  - ⬜ Language picker
  - ⬜ Notification preferences toggle
  - ⬜ Buyer/Seller role toggle
  - ⬜ Dark mode toggle

### Marketplace
- ✅ `MarketplaceScreen` — `/marketplace` (filters, chips, property cards, FAB, real API data)
  - ✅ Category, location, type, seller, price, size filters
  - ✅ Save/unsave properties
  - ✅ Property detail screen with image gallery (full-screen PageView + dot indicators)
  - ✅ Image display from `property.images` (loading spinner + error fallback)
  - ⬜ Pagination / infinite scroll
  - ⬜ Search bar integration
  - ⬜ Sort options (price, date, location)
- ⬜ `SearchResultsScreen` — `/search-results`

### Properties
- ✅ `SavedPropertiesScreen` — `/saved-properties` (real API data)
  - ⬜ Image display in saved property cards
- ✅ `CreatePropertyScreen` — `/create-property` (checks canSell, verification prompt if not verified, edit mode)
  - ✅ Image picker (FileType.image — any format)
  - ✅ Upload to ImageKit.io (falls back to Supabase Storage)
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
- ✅ `KingdomProjectsScreen` — `/kingdom-projects` (Coming Soon placeholder)
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
- ✅ ImageKit.io integration for property images (CDN, optimization, resizing)
  - ✅ `ImageKitService` — upload via REST API with private key auth
  - ✅ Falls back to Supabase Storage if ImageKit not configured
  - ⬜ Avatar upload via ImageKit
  - ⬜ Project image upload via ImageKit
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

### Property Images — ✅ Complete
- ✅ ImageKit.io service — upload via REST API, CDN delivery
- ✅ Supabase Storage fallback when ImageKit not configured
- ✅ SQL migration `00007_storage_property_images.sql` — storage bucket + RLS
- ✅ Extract `PropertyCard` to standalone widget
- ✅ Render `Image.network` from `property.images` in cards
- ✅ Build `PropertyDetailScreen` with swipeable image gallery
- ✅ Loading spinner and error fallback for images
- ✅ 8-image limit per property post

### Property Management (Seller)
- ✅ Edit property (pre-fill form from `existingProperty`, update images, resubmit)
- ✅ Delete property with confirmation dialog
- ✅ Status badge (draft/pending/approved/rejected/archived) with colored chip
- ✅ Rejection reason display
- ✅ Submit draft for review
- ✅ Archive / Reactivate property
- ⬜ Analytics (views, saves count)

### Profile & Settings — ⬜ Not Started
- ⬜ Avatar image upload (crop, resize, store in `avatars` bucket)
- ⬜ Change Password (Supabase `updateUser` with current password verification)
- ⬜ Phone/email verification badge
- ⬜ Language picker with i18n
- ⬜ Notification preferences (push vs email)
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

### Daily Portion
- ⬜ Fetch from `daily_portions` table
- ⬜ Bookmark/read status tracking
- ⬜ Daily refresh logic
- ⬜ Rich text rendering for portion content

### Notifications
- ⬜ Fetch from `notifications` table
- ⬜ Read/unread state
- ⬜ Push notification integration
- ⬜ In-app notification badge

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
- ✅ `src/app/verification/page.tsx` — Filterable request list, approve/reject modal
- ✅ `src/app/properties/page.tsx` — Property approval list with reject modal
- ✅ `src/app/projects/page.tsx` — Project approval list with progress bars
- ✅ `src/lib/admin-layout.tsx` — Sidebar nav + top bar + logout modal + mobile hamburger
- ✅ `src/lib/auth-context.tsx` — React context for JWT auth
- ✅ `src/lib/api-client.ts` — Typed fetch wrapper with JWT Bearer
- ✅ `src/lib/toast.tsx` — Toast notification system

### Backend (11 API routes, no Express)
- ✅ Auth: POST `/api/auth/login`
- ✅ Dashboard: GET `/api/dashboard`
- ✅ Verification: GET list, POST approve, POST reject
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
- ⬜ Migration: `00008_storage_avatars.sql`

---

## Technology Stack
- ✅ Flutter 3.19+ with Material 3
- ✅ Supabase Flutter ^2.5.0
- ✅ google_fonts ^6.1.0 (Inter)
- ✅ flutter_dotenv — environment variables
- ✅ file_picker — document/image uploads
- ✅ ImageKit.io — cloud image CDN with optimization (`ImageKitService`, REST API upload)
- ✅ `http` ^1.2.0 — HTTP client for ImageKit API
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
- ✅ `.env` gitignored

## Design
- ✅ `AppTheme` — full Serene Covenant palette (50+ color tokens), Inter typography
- ✅ `BottomNavBar` — reusable with Daily, Market, Kingdom, Profile tabs
- ✅ Profile card — gradient avatar, compact badges, professional layout

---

## Next Priority Order
1. ✅ **Property Images** — migration, ImageKit, card, image display, detail screen, 8-image limit
2. ✅ **Property Management** — edit/delete/archive/reactivate, status badges, rejection reason, submit draft
3. ⬜ **Profile & Settings** — avatar upload, change password, preferences
4. ⬜ **Kingdom Projects** — full CRUD, donations
5. ⬜ **Reviews & Ratings**
6. ⬜ **Daily Portion** — real data
7. ⬜ **Notifications** — real data, push
8. ⬜ **Search** — cross-entity
9. ⬜ **Infrastructure** — error tracking, caching, CI/CD
