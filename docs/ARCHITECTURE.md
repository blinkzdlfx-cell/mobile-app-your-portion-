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
