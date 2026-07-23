import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../config/app_protection.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    // Enable screen protection in release mode
    if (AppProtection.isReleaseMode) {
      AppProtection.enableScreenProtection();
    }
  }

  void _onOAuthSignIn() {
    _authSub?.cancel();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedIn) {
        _authSub?.cancel();
        if (!mounted) return;
        final role = event.session?.user.userMetadata?['role'] as String?;
          Navigator.pushReplacementNamed(context, '/home');
        }
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      _onOAuthSignIn();
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.flutter://callback',
      );
    } catch (error) {
      _authSub?.cancel();
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google sign-in failed. Please try again.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      _onOAuthSignIn();
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: kIsWeb ? null : 'io.supabase.flutter://callback',
      );
    } catch (error) {
      _authSub?.cancel();
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apple sign-in failed. Please try again.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Sign in with Supabase
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (response.user != null) {
          String? role = response.user!.userMetadata?['role'] as String?;

          if (role == null || role.isEmpty) {
            try {
              final profileRes = await Supabase.instance.client
                  .from('profiles')
                  .select('role')
                  .filter('id', 'eq', response.user!.id)
                  .single();
              role = profileRes['role'] as String?;
              if (role != null && role.isNotEmpty) {
                await Supabase.instance.client.auth.updateUser(
                  UserAttributes(data: {'role': role}),
                );
              }
            } catch (_) {}
          }

          setState(() => _isLoading = false);

          Navigator.pushReplacementNamed(context, '/home');
          return;
        }
      }

      setState(() => _isLoading = false);
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        final errMsg = error.toString();
        String userMsg;
        if (errMsg.contains('Invalid login credentials')) {
          userMsg = 'Wrong email or password. Please check and try again.';
        } else if (errMsg.contains('Email not confirmed')) {
          userMsg = 'Please verify your email address first. Check your inbox.';
        } else if (errMsg.contains('rate_limit')) {
          userMsg = 'Too many attempts. Please wait a moment and try again.';
        } else {
          userMsg = 'Sign in failed. Please check your connection and try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMsg),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 48),
                        // Logo and Brand
                        Column(
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your Portion',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        // Welcome Header
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: AppTheme.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 28,
                                height: 1.21,
                                letterSpacing: -0.01,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to continue your journey of faith, stewardship, and community.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Email Input
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Email Address',
                            prefixIcon: Icon(
                              Icons.mail_outline,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Password Input
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppTheme.onSurfaceVariant,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppTheme.onSurfaceVariant,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Remember Me & Forgot Password
                        Row(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() => _rememberMe = value ?? false);
                                  },
                                  activeColor: AppTheme.primaryContainer,
                                  checkColor: AppTheme.onPrimary,
                                ),
                                Text(
                                  'Remember Me',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/forgot-password');
                              },
                              child: Text(
                                'Forgot Password?',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppTheme.primaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Sign In Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryContainer,
                            foregroundColor: AppTheme.onPrimary,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.onPrimary),
                                  ),
                                )
                              : Text(
                                  'Sign In',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppTheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.05,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),
                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppTheme.surfaceVariant)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or continue with',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: AppTheme.surfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Social Login Buttons
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          icon: Text(
                            'G',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          label: Text(
                            'Continue with Google',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            side: const BorderSide(color: AppTheme.outlineVariant),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleAppleSignIn,
                          icon: Icon(
                            Icons.apple,
                            color: AppTheme.onSurface,
                          ),
                          label: Text(
                            'Continue with Apple',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            side: const BorderSide(color: AppTheme.outlineVariant),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Create Account Link
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.onSurfaceVariant,
                                ),
                                children: [
                                  const TextSpan(text: "Don't have an account? "),
                                  TextSpan(
                                    text: 'Create Account',
                                    style: TextStyle(
                                      color: AppTheme.primaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Security Badge
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 14,
                                color: AppTheme.outline,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Your information is securely protected.',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppTheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}