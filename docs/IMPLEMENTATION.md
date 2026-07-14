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
1. `SplashScreen` → checks session → `OnboardingScreen` (new user) or `HomeScreen` (existing)
2. Onboarding (3-page PageView) → `LoginScreen` or `SignupScreen`
3. Login/Signup via `Supabase.instance.client.auth.signInWithPassword()` / `signUp()`
4. Google/Apple via `signInWithOAuth(OAuthProvider.google/apple)`
5. On first login → `ChooseRoleScreen` → saves role to `auth.updateUser(data: {'role': ...})` + `profiles.upsert({...})` → navigates to `/home`
6. Forgot password via `resetPasswordForEmail()` (not yet implemented in code)

## Role Gating Pattern
- `SupabaseService.canSell()` fetches profile and returns `isSellerVerified && (role == 'seller' || role == 'both')`
- Called in `didChangeDependencies` with `_initialized` flag to avoid double-fetch
- Marketplace FAB: shows "Create Property" if `canSell`, otherwise "Become a Seller" CTA that opens verification bottom sheet
- Kingdom Projects: button to create project shown only if `canSell`

## Database Schema (`supabase/migrations/00001_seller_buyer_schema.sql`)
**6 tables + 1 function + 1 trigger**:
1. `profiles` — Extends `auth.users` with role, contact, trust flags
2. `properties` — Seller listings (category, price, location, bedrooms, contact info, status)
3. `saved_properties` — User favorites (unique user_id + property_id)
4. `kingdom_projects` — Projects with goal/raised amounts, status, contact info
5. `project_donations` — Donor contributions to projects
6. `reviews` — Ratings (1-5) and comments on properties

**Trigger**: `handle_new_user()` auto-creates profile on auth signup

## RLS Policies
- Profiles: anyone can SELECT, users UPDATE own
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

### Role Helpers
- `canSell()` → `bool`
