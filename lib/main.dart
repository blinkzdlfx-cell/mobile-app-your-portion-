// AI NOTE: Before making any changes, read docs/ for project context:
//   - PRD.md          — Product requirements, user stories, roles
//   - TECH_STACK.md   — Stack, versions, folder structure
//   - IMPLEMENTATION.md — Routes, auth flow, schema, code patterns
//   - PROGRESS.md     — What's done, in progress, and gaps
//   - RULES.md        — Coding conventions and rules
//   - ARCHITECTURE.md — Data flow, nav map, widget tree, ER diagram

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'config/app_protection.dart';
import 'services/imagekit_service.dart';
import 'models/property.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/choose_role_screen.dart';
import 'screens/onboarding/document_upload_screen.dart';
import 'screens/onboarding/become_trusted_member_screen.dart';
import 'screens/onboarding/seller_verification_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/daily_portion_screen.dart';
import 'screens/home/notifications_screen.dart';
import 'screens/home/profile_screen.dart';
import 'screens/home/edit_profile_screen.dart';
import 'screens/home/settings_screen.dart';
import 'screens/marketplace/marketplace_screen.dart';
import 'screens/marketplace/search_results_screen.dart';
import 'screens/properties/saved_properties_screen.dart';
import 'screens/properties/my_properties_screen.dart';
import 'screens/properties/create_property_screen.dart';
import 'screens/properties/bookmarked_portions_screen.dart';
import 'screens/properties/property_detail_screen.dart';
import 'screens/kingdom_projects/kingdom_projects_screen.dart';
import 'screens/kingdom_projects/create_kingdom_project_screen.dart';
import 'screens/library/learning_library_screen.dart';
import 'screens/utility/loading_screen.dart';
import 'screens/utility/offline_screen.dart';
import 'screens/utility/empty_state_screen.dart';
import 'screens/utility/success_screen.dart';
import 'screens/utility/help_support_screen.dart';
import 'screens/settings/trusted_member_status_screen.dart';
import 'screens/settings/change_password_screen.dart';
import 'screens/settings/notification_settings_screen.dart';
import 'screens/settings/buyer_seller_role_screen.dart';
import 'screens/settings/language_picker_screen.dart';
import 'screens/settings/contact_us_screen.dart';
import 'screens/settings/send_feedback_screen.dart';
import 'screens/settings/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: "assets/.env");
  ImageKitService().init();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '',
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Validate app integrity in release mode
  if (AppProtection.isReleaseMode) {
    final bool isValid = await AppProtection.validateAppIntegrity();
    if (!isValid) {
      debugPrint('App integrity check failed');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Portion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        // Auth & Onboarding
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/choose-role': (context) => const ChooseRoleScreen(),
        '/document-upload': (context) => const DocumentUploadScreen(),
        '/become-trusted-member': (context) => const BecomeTrustedMemberScreen(),
        '/seller-verification': (context) => const SellerVerificationScreen(),
        // Home
        '/home': (context) => const HomeScreen(),
        '/daily-portion': (context) => const DailyPortionScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        // Marketplace & Properties
        '/marketplace': (context) => const MarketplaceScreen(),
        '/search-results': (context) => const SearchResultsScreen(),
        '/my-properties': (context) => const MyPropertiesScreen(),
        '/saved-properties': (context) => const SavedPropertiesScreen(),
        '/bookmarked-portions': (context) => const BookmarkedPortionsScreen(),
        '/property-detail': (context) => const PropertyDetailScreen(),
        '/create-property': (context) {
          final existing = ModalRoute.of(context)?.settings.arguments;
          return CreatePropertyScreen(existingProperty: existing is Property ? existing : null);
        },
        // Kingdom Projects
        '/kingdom-projects': (context) => const KingdomProjectsScreen(),
        '/create-kingdom-project': (context) => const CreateKingdomProjectScreen(),
        // Library
        '/learning-library': (context) => const LearningLibraryScreen(),
        // Utility
        '/loading': (context) => const LoadingScreen(),
        '/offline': (context) => const OfflineScreen(),
        '/empty-state': (context) => const EmptyStateScreen(),
        '/success': (context) => const SuccessScreen(message: 'Operation completed successfully.'),
        '/help-support': (context) => const HelpSupportScreen(),
        // Settings
        '/trusted-member-status': (context) => const TrustedMemberStatusScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/notification-settings': (context) => const NotificationSettingsScreen(),
        '/buyer-seller-role': (context) => const BuyerSellerRoleScreen(),
        '/language': (context) => const LanguagePickerScreen(),
        '/contact-us': (context) => const ContactUsScreen(),
        '/send-feedback': (context) => const SendFeedbackScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}
