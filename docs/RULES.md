# Your Portion — AI Coding Rules

## Navigation & Routes
- **Never** remove or rename existing routes in `main.dart`. Add new routes only.
- Use `pushNamed` / `pushReplacementNamed` for navigation. Avoid `Navigator.push(MaterialPageRoute(...))`.
- Pass data via `ModalRoute.of(context)?.settings.arguments`.

## Supabase & Data
- Always import `package:supabase_flutter/supabase_flutter.dart` for auth/db calls.
- Access client via `Supabase.instance.client` or inject via `SupabaseService()`.
- **Filter via Dart-side `.where()`** — do NOT use `.eq()` on `PostgrestTransformBuilder` (not available in supabase-dart v2.13).
- Always dispose controllers and focus nodes in `dispose()`.
- Check `mounted` before state changes after async work.

## Role Gating
- Load seller status in `didChangeDependencies` with a `_initialized` flag to prevent double-fetch.
- Use `SupabaseService.canSell()` to check if user can create properties/projects.
- Default role is `buyer`; all users can browse, save, donate, review.

## Theme & Styling
- Use `AppTheme` color/text constants exclusively — never hardcode colors or font sizes.
- Use `Theme.of(context).textTheme.*` for text styles, `AppTheme.*` for colors.
- Wrap overflow-prone layouts in `SingleChildScrollView`.
- Use `SafeArea` on outermost Scaffold body.

## File & Class Conventions
- File names: `snake_case`
- Class names: `PascalCase`
- Private widgets within screen files: `_WidgetName` (e.g., `_CategoryCard`, `_FilterChip`)
- Private helpers: `_methodName`

## Patterns to Follow
- Animated search bars: `AnimatedContainer` + `FocusNode`
- Filter bottom sheets: `showModalBottomSheet` + `StatefulBuilder` + `setSheetState`
- Loading states: `CircularProgressIndicator` in button during async
- Verification gating: bottom sheet with explanation + link to profile
- Ambient shadow: `AppTheme.ambientShadow`

## State Management
- No external state management packages. Use `StatefulWidget` local state.
- Auth state is derived from `Supabase.instance.client.auth.currentUser` directly.
