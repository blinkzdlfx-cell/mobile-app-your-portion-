# Your Portion — Implementation Details

## Navigation
All routes defined in `main.dart:83-116` as named routes in `MaterialApp.routes`:
- **Auth & Onboarding**: `/login`, `/signup`, `/forgot-password`, `/welcome`, `/splash`, `/onboarding`, `/choose-role`, `/become-trusted-member`
- **Home**: `/home`, `/daily-portion`, `/notifications`, `/profile`, `/edit-profile`, `/settings`
- **Marketplace**: `/marketplace`, `/search-results`, `/saved-properties`, `/create-property`
- **Kingdom Projects**: `/kingdom-projects`, `/create-kingdom-project`
- **Library**: `/learning-library`
- **Utility**: `/loading`, `/offline`, `/empty-state`, `/success`, `/help-support`

Navigation uses `pushNamed` / `pushReplacementNamed`. No `Navigator 2.0` or `go_router`.

## Authentication Flow
1. `SplashScreen` → `WelcomeScreen` (no session check — always shows branding animation)
2. Welcome screen → `LoginScreen` or `SignupScreen`
3. Login/Signup via `Supabase.instance.client.auth.signInWithPassword()` / `signUp()`
4. Google/Apple via `signInWithOAuth(OAuthProvider.google/apple)`
5. On first login/signup → `ChooseRoleScreen`
   - If no session (unconfirmed email) → shows "Verify Your Email" screen with "Go to Sign In" button
   - If session exists → shows Buyer/Seller role selection
   - Role saved to `auth.updateUser(data: {'role': ...})` + `profiles.update({...}).filter('id', 'eq', user.id)`
   - Buyer → navigates to `/home`
   - Seller → navigates to `/document-upload`
6. `DocumentUploadScreen` — seller uploads government ID (NIN/Voter Card/Passport) + face image → admin verifies
7. Forgot password via `resetPasswordForEmail()` (not yet implemented in code)

## Role Gating Pattern
- `SupabaseService.canSell()` fetches profile and returns `isSellerVerified && (role == 'seller' || role == 'both')`
- Called in `didChangeDependencies` with `_initialized` flag to avoid double-fetch
- Marketplace **FAB**: always shows **+** icon (no role check). Everyone can browse.
- `CreatePropertyScreen`: checks `canSell()` on entry:
  - If not verified → shows "Verification Required" prompt with "Go to Profile to Verify" button
  - If verified → shows property listing form
- Kingdom Projects: replaced with "Coming Soon" placeholder screen

## Database Schema (6 migration files)

### `00001_seller_buyer_schema.sql` — Core schema
**6 tables + 1 function + 1 trigger**:
1. `profiles` — Extends `auth.users` with role, contact, trust flags
2. `properties` — Seller listings (category, price, location, bedrooms, contact info, status)
3. `saved_properties` — User favorites (unique user_id + property_id)
4. `kingdom_projects` — Projects with goal/raised amounts, status, contact info
5. `project_donations` — Donor contributions to projects
6. `reviews` — Ratings (1-5) and comments on properties
**Trigger**: `handle_new_user()` auto-creates profile on auth signup

### `00002_bookmarked_portions.sql` — Daily portion bookmarks
### `00003_verification_requests.sql` — Seller + trusted member verification requests
### `00004_add_id_document_url.sql` — Storage bucket for verification documents
### `00005_add_id_type_and_face_image.sql` — `id_type` + `face_image_url` columns
### `00006_add_profiles_insert_policy.sql` — Profiles INSERT policy (safety net)

## RLS Policies
- Profiles: anyone SELECT, users INSERT own, users UPDATE own
- Properties: anyone SELECT approved or own; sellers INSERT (must be verified); sellers UPDATE/DELETE own
- Saved Properties: users manage own
- Kingdom Projects: anyone SELECT active/completed or own; sellers INSERT (verified); creators UPDATE/DELETE own
- Donations: anyone SELECT, buyers INSERT (donor_id = auth.uid())
- Reviews: anyone SELECT, buyers INSERT/UPDATE own

## Key Coding Patterns
- **Filtering**: Dart-side `.where()` on fetched lists (no SQL `.eq()` — `PostgrestTransformBuilder` in supabase-dart v2.13 doesn't support chained `.eq()` directly)
- **Private widgets**: `_CategoryCard`, `_FilterChip`, `_PropertyCard`, `_RoleCard`, `_NavItem` defined as private classes within screen files
- **Filter system**: Horizontal `ListView` of `_FilterChip` widgets + bottom sheet with `DropdownButtonFormField`s and `RangeSlider`s
- **Search**: Collapsible `AnimatedContainer` on home screen, expands to full `TextField` with `onSubmitted` → `/search-results`
- **Seller verification**: ID type chips (NIN/Voter Card/Passport) + gov ID file upload + face image upload
- **Profile card**: Gradient header with initials, compact badges row, role-based item visibility
- **Theme**: All colors/text styles from `AppTheme` constants, never hardcoded
- **Disposal**: All `TextEditingController`s, `FocusNode`s, `AnimationController`s disposed in `dispose()`

## SupabaseService Methods
### Profile
- `getCurrentProfile()` → `UserProfile?`
- `updateProfile(Map<String, dynamic>)` → void

### Properties
- `getProperties({String? category})` → `List<Property>`
- `getMyProperties()` → `List<Property>`
- `createProperty(Property)` → void
- `updateProperty(String id, Map<String, dynamic>)` → void
- `deleteProperty(String id)` → void

### Saved Properties
- `getSavedPropertyIds()` → `List<String>`
- `saveProperty(String propertyId)` → void
- `unsaveProperty(String propertyId)` → void

### Kingdom Projects
- `getProjects()` → `List<KingdomProject>` (filters active/completed)
- `getMyProjects()` → `List<KingdomProject>`
- `createProject(KingdomProject)` → void

### Bookmarked Portions
- `getBookmarkedPortions()` → `List<Map<String, dynamic>>`
- `isPortionBookmarked(String portionId)` → `bool`
- `bookmarkPortion(String portionId)` → void
- `removeBookmarkedPortion(String portionId)` → void

### Verification Requests
- `submitVerificationRequest({requestType, fullName, phone, reason, idDocumentUrl, idType, faceImageUrl})` → void
- `getPendingRequest(String requestType)` → `Map<String, dynamic>?`

### Files / Storage
- `uploadFile(String bucket, String path, String filePath)` → `String?` (generic)
- `uploadVerificationDocument(String filePath)` → `String?`
- `uploadFaceImage(String filePath)` → `String?`

### Admin Methods
- `getPendingVerificationRequests()` → `List<Map<String, dynamic>>`
- `getPendingProperties()` → `List<Map<String, dynamic>>`
- `getPendingProjects()` → `List<Map<String, dynamic>>`
- `approveVerificationRequest(String requestId, String userId, String requestType)` → void
- `rejectVerificationRequest(String requestId, String reason)` → void
- `approveProperty(String propertyId)` → void
- `rejectProperty(String propertyId, String reason)` → void
- `approveProject(String projectId)` → void
- `rejectProject(String projectId, String reason)` → void

## Admin Dashboard Server

The admin dashboard is a **separate web app** (not a Flutter screen) at `admin-dashboard/`. It consists of:

### Frontend (`admin-dashboard/`)
- **`index.html`** — SPA with 4 tabs (Dashboard, Verification, Properties, Projects)
- **`styles.css`** — Full styling including login page, cards, modals, toasts
- **`scripts/api.js`** — API client, all functions exposed globally (no module system)
- **`scripts/app.js`** — SPA logic: auth check, navigation, data loading, CRUD, rejection modal

### Backend (`admin-dashboard/server/`)
- **`index.js`** — Express server on port 3000, serves static files + REST API
- **`setup.js`** — Interactive CLI to generate `.env` with Supabase + admin credentials
- Uses `@supabase/supabase-js` with **service role key** (bypasses RLS)
- JWT-based admin auth with bcrypt password verification
- Graceful startup — serves login page even without Supabase configured

### Setup
```sh
cd admin-dashboard/server
npm install
npm run setup   # or manually create .env from .env.example
npm start       # → http://localhost:3000
```

## Deploying the Admin Dashboard

See `docs/DEPLOY_ADMIN.md` for full deployment instructions covering Render, Railway, and Fly.io.

### Role Helpers
- `canSell()` → `bool`
- `isAdmin()` → `bool`
