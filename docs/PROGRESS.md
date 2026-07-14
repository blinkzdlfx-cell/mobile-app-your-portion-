# Your Portion — Progress Tracker

## Legend
- ✅ Complete
- 🔄 In Progress
- ⬜ Not Started
- ❌ Blocked

---

## Screens (27 routes)

### Auth & Onboarding
- ✅ `SplashScreen` — `/splash`
- ✅ `OnboardingScreen` — `/onboarding` (3-page carousel)
- ✅ `WelcomeScreen` — `/welcome`
- ✅ `LoginScreen` — `/login` (email/password + Google + Apple)
- ✅ `SignupScreen` — `/signup` (email/password + Google + Apple)
- ✅ `ForgotPasswordScreen` — `/forgot-password`
- ✅ `ChooseRoleScreen` — `/choose-role` (buyer/seller/both)
- ✅ `BecomeTrustedMemberScreen` — `/become-trusted-member`

### Home
- ✅ `HomeScreen` — `/home` (greeting, search, daily portion, categories, kingdom preview)
- 🔄 `DailyPortionScreen` — `/daily-portion` (UI exists, real data integration needed)
- 🔄 `NotificationsScreen` — `/notifications`
- 🔄 `ProfileScreen` — `/profile`
- 🔄 `EditProfileScreen` — `/edit-profile`
- 🔄 `SettingsScreen` — `/settings`

### Marketplace
- ✅ `MarketplaceScreen` — `/marketplace` (filters, chips, property cards, role-gated FAB, real API data integration)
- ⬜ `SearchResultsScreen` — `/search-results`

### Properties
- ✅ `SavedPropertiesScreen` — `/saved-properties` (real API data integration)
- 🔄 `CreatePropertyScreen` — `/create-property`

### Kingdom Projects
- ✅ `KingdomProjectsScreen` — `/kingdom-projects`
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
- ✅ `SupabaseService` — all CRUD methods (profile, properties, saved, projects)
- ✅ Supabase initialization in `main.dart`
- ✅ Real API data in marketplace (updated to use SupabaseService)
- ✅ Real API data in saved properties (updated to use SupabaseService)
- ✅ Real API data in my properties (updated to use SupabaseService)
- ⬜ Real API data in kingdom projects
- ⬜ Real API data in daily portion
- ⬜ Upload/display property images
- ⬜ Review creation & display
- ⬜ Project donation flow

## Models
- ✅ `UserProfile` — with `canSell`, `canBuy`, `isBoth`, `displayRole`, `firstName`
- ✅ `Property` — with `formattedPrice`, `fromMap`, `toMap`
- ✅ `KingdomProject` — with `progressPercent`, `fromMap`, `toMap`

## Database
- ✅ Migration: `00001_seller_buyer_schema.sql` (6 tables, RLS, trigger)
- ✅ Schema diagram in migration file
- ⬜ Executed in Supabase project (requires manual SQL run)

## Security
- ✅ `AppProtection` — root/jailbreak detection, screen protection, debug detection
- ✅ RLS policies in schema
- ✅ `.env` gitignored

## Infrastructure
- ✅ GitHub Actions keep-alive workflow — weekly Supabase ping to prevent free-tier sleep

## Design
- ✅ `AppTheme` — full Serene Covenant palette (50+ color tokens), Inter typography, input/button themes
- ✅ `BottomNavBar` — reusable with Daily, Market, Kingdom, Profile tabs

## Known Gaps
- `SearchResultsScreen` — shell exists but no content
- `DailyPortionScreen` — no real data fetching
- `NotificationsScreen` — no real data
- `ProfileScreen` — reads from `auth.currentUser.userMetadata`, not `SupabaseService.getCurrentProfile()`
- Property images — placeholder only (no asset URL or upload)
- Most screens use hardcoded mock data (marketplace, kingdom projects)
- No error boundary / crash reporting
- No image caching or lazy loading
- No dark mode
- No localization / i18n
