# Your Portion - Authentication Screens

## Overview

This document describes the authentication screens implementation for the Your Portion mobile app, based on the Serene Covenant design system.

## Design System

The app follows the **Serene Covenant** design system with the following characteristics:

- **Color Palette**: Deep Forest Green (#012d1d) primary, Pure White (#fcf9f8) background, Sage Green accents
- **Typography**: Inter font family with systematic precision and neutral elegance
- **Spacing**: 8px baseline grid with generous whitespace
- **Shapes**: High roundedness (12px for inputs/buttons, 16px for cards)
- **Elevation**: Ambient shadows (0px 10px 30px rgba(0, 0, 0, 0.04))

## Screens Implemented

### 1. Login Screen (`lib/screens/auth/login_screen.dart`)

**Features:**
- Email and password input fields with Material Icons
- Password visibility toggle
- "Remember Me" checkbox
- "Forgot Password?" link
- Primary "Sign In" button with loading state
- Social login options (Google, Apple)
- "Create Account" navigation link
- Security badge

**Design Elements:**
- Logo with ambient shadow
- "Welcome Back" headline
- Form validation
- Ambient shadow on primary button
- Responsive layout with SafeArea

### 2. Signup Screen (`lib/screens/auth/signup_screen.dart`)

**Features:**
- Full name, email, password, and confirm password fields
- Password visibility toggles for both fields
- Terms of Service and Privacy Policy agreement checkbox
- "Create Account" button with loading state
- Social sign-up options (Google, Apple)
- "Sign In" navigation link for existing users
- Security badge

**Design Elements:**
- Larger logo (64x64) with ambient shadow
- "Join the Community" headline
- Form validation with password matching
- Ambient shadow on primary button
- Secure registration badge

### 3. Forgot Password Screen (`lib/screens/auth/forgot_password_screen.dart`)

**Features:**
- Email input field
- "Send Reset Link" button with loading state
- Success dialog showing confirmation message
- Info card with helpful tip about spam folder
- "Sign In" link to return to login

**Design Elements:**
- Top app bar with back button and centered title
- Lock reset icon header
- "Forgot Your Password?" headline
- Info card with icon
- Success dialog with email confirmation

## Project Structure

```
mobile-app/your_portion/
├── lib/
│   ├── config/
│   │   └── app_protection.dart          # Anti-tampering protection
│   ├── theme/
│   │   └── app_theme.dart               # Serene Covenant theme
│   ├── screens/
│   │   └── auth/
│   │       ├── login_screen.dart        # Login screen
│   │       ├── signup_screen.dart       # Signup screen
│   │       └── forgot_password_screen.dart  # Forgot password
│   └── main.dart                        # App entry point
```

## Security Features

### App Protection (`lib/config/app_protection.dart`)

The app includes protection mechanisms to prevent tampering:

1. **Debug Mode Detection**: Identifies if app is running in debug mode
2. **Release Mode Validation**: Performs integrity checks in release builds
3. **Root/Jailbreak Detection**: Checks for common rooting/jailbreaking indicators
4. **Screen Protection**: Prevents screenshots and screen recording (platform-specific)
5. **Tampering Detection**: Framework for detecting app modifications

**Usage:**
```dart
import 'config/app_protection.dart';

// Check if in debug mode
if (AppProtection.isDebugMode) {
  // Debug-specific behavior
}

// Enable screen protection in release mode
if (AppProtection.isReleaseMode) {
  AppProtection.enableScreenProtection();
}

// Validate app integrity
bool isValid = await AppProtection.validateAppIntegrity();
```

## Theme Configuration (`lib/theme/app_theme.dart`)

Complete implementation of the Serene Covenant design system:

- **Color Palette**: All colors from the design specification
- **Typography**: Inter font with proper sizing, spacing, and weights
- **Input Decoration**: Rounded corners (12px), focus states, proper padding
- **Button Themes**: Elevated and outlined button styles
- **Ambient Shadow**: Reusable shadow for elevated elements

**Color Usage:**
- `primaryContainer`: Main action buttons (#1b4332)
- `onPrimary`: Text on primary buttons (#ffffff)
- `surfaceContainer`: Input field backgrounds (#f0edec)
- `onSurfaceVariant`: Secondary text (#414844)
- `outlineVariant`: Borders and dividers (#c1c8c2)

## Running the App

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / Xcode for mobile deployment

### Installation

1. Navigate to the project directory:
   ```bash
   cd mobile-app/your_portion
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   # For debug mode
   flutter run
   
   # For specific platform
   flutter run -d chrome  # Web
   flutter run -d android  # Android
   flutter run -d ios      # iOS (macOS only)
   ```

### Build for Release

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Navigation

The app uses named routes defined in `main.dart`:

- `/login` - Login screen (default)
- `/signup` - Signup screen
- `/forgot-password` - Forgot password screen

**Example navigation:**
```dart
// Navigate to signup
Navigator.pushNamed(context, '/signup');

// Navigate to forgot password
Navigator.pushNamed(context, '/forgot-password');

// Go back
Navigator.pop(context);
```

## Form Validation

All forms include comprehensive validation:

- **Email**: Required, must contain '@'
- **Password**: Required, minimum 6-8 characters
- **Confirm Password**: Must match password
- **Full Name**: Required
- **Terms Agreement**: Required for signup

## State Management

Each screen manages its own state using `StatefulWidget`:

- Form controllers for input fields
- Loading states for async operations
- Password visibility toggles
- Checkbox states

## Next Steps

1. **Integrate Backend**: Connect forms to actual API endpoints
2. **Add Authentication**: Implement Firebase Auth or custom auth
3. **Social Login**: Configure Google and Apple Sign-In
4. **Add Screens**: Implement home dashboard and other app screens
5. **Add Animations**: Implement fade-in and transition animations
6. **Testing**: Add unit and widget tests
7. **Localization**: Add multi-language support

## Design References

- Design Documentation: `stitch_your_portion_app_design/serene_covenant_DESIGN.md`
- HTML Mockups: `stitch_your_portion_app_design/login_welcome_back_code.html`
- HTML Mockups: `stitch_your_portion_app_design/create_account_join_the_community_1_code.html`
- HTML Mockups: `stitch_your_portion_app_design/forgot_password_your_portion_code.html`

## Notes

- All screens implement the Serene Covenant design system
- Anti-tampering protection is active in release mode
- Screen protection prevents screenshots in production
- Forms include proper validation and error handling
- Loading states provide user feedback during async operations
- The app uses Material 3 design principles

## Support

For issues or questions, refer to the main project documentation or contact the development team.