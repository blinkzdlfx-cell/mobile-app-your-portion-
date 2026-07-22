# Your Portion — Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| **Language** | Dart | ^3.12.0 |
| **Framework** | Flutter | 3.x (Material 3) |
| **Auth & Database** | supabase_flutter | ^2.5.0 |
| **Database Client** | supabase (Dart) | ^2.13.4 |
| **Fonts** | google_fonts | ^6.1.0 (Inter) |
| **Env Variables** | flutter_dotenv | ^5.1.0 |
| **Icons** | Material Icons + Cupertino Icons | ^1.0.8 |
| **Image CDN** | ImageKit.io (REST API upload, auto-optimization) | — |
| **HTTP Client** | http | ^1.2.0 |
| **Linting** | flutter_lints | ^6.0.0 |
| **Database** | PostgreSQL (via Supabase) | — |
| **CI** | GitHub Actions (keep-alive) | — |

## State Management
- **None**: Each screen manages its own state via `StatefulWidget`
- Local state only (no Provider, Riverpod, or Bloc)
- Auth state derived from `Supabase.instance.client.auth.currentUser`

## Design System
- **Name**: Serene Covenant
- **Palette**: Deep Forest Green (#012d1d) primary, Sage (#1b4332) container, Pure White (#fcf9f8) surface
- **Typography**: Inter (weights 400, 500, 600), defined in `app_theme.dart`
- **Shapes**: 12px radius for inputs/buttons, 16px for cards
- **Shadows**: `AppTheme.ambientShadow` (0px 10px 30px rgba(0,0,0,0.04))

## Project Structure
```
lib/
├── config/
│   └── app_protection.dart      # Root/jailbreak detection, screen protection
├── models/
│   ├── user_profile.dart         # UserProfile with role logic
│   ├── property.dart             # Property listing model
│   └── kingdom_project.dart      # Kingdom project model
├── screens/
│   ├── auth/                     # login, signup, forgot_password
│   ├── home/                     # home, daily_portion, notifications, profile, edit_profile, settings
│   ├── marketplace/              # marketplace, search_results
│   ├── onboarding/               # onboarding, welcome, choose_role, become_trusted_member
│   ├── properties/               # create_property, saved_properties
│   ├── kingdom_projects/         # kingdom_projects, create_kingdom_project
│   ├── library/                  # learning_library
│   ├── splash/                   # splash, splash_textured
│   └── utility/                  # loading, offline, empty_state, success, help_support
├── services/
│   ├── supabase_service.dart     # All Supabase CRUD operations
│   └── imagekit_service.dart     # ImageKit.io upload via REST API
├── theme/
│   └── app_theme.dart            # Serene Covenant theme constants
├── widgets/
│   ├── bottom_nav_bar.dart       # Reusable bottom navigation
│   └── property_card.dart        # Property card with image, save, navigation
└── main.dart                     # Entry point, routes, Supabase init
```
