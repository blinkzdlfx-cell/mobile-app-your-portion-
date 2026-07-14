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
  → OnboardingScreen (3-page carousel, "Skip" → Login)
  → LoginScreen ↔ SignupScreen ↔ ForgotPasswordScreen
  → ChooseRoleScreen → HomeScreen
  → (BecomeTrustedMemberScreen)

HomeScreen (bottom nav: 0=Daily)
  ├── /search-results
  ├── /marketplace (bottom nav: 1=Market)
  │     ├── /search-results
  │     ├── /saved-properties
  │     └── /create-property (seller only)
  ├── /kingdom-projects (bottom nav: 2=Kingdom)
  │     └── /create-kingdom-project (seller only)
  └── /profile (bottom nav: 3=Profile)
        ├── /edit-profile
        ├── /settings
        ├── /saved-properties
        └── /help-support
```

## Auth Flow Diagram
```
User → Signup (/signup)
  → Supabase.auth.signUp(email, password, data)
  → Profiles created via trigger handle_new_user()
  → Navigate to /login
  → Supabase.auth.signInWithPassword(email, password)
  → If first login → ChooseRoleScreen
  → Role saved to auth.user_metadata + profiles table
  → Navigate to /home
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
