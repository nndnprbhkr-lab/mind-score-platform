import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passwordCtrl.text);
  }

  void _onGoogleTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-in coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    ref.listen(authProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: kAuthBg,
      body: Stack(
        children: [
          const AuthGlowCircle(
              size: 320, color: Color(0x1A6B35C8), top: -120, right: -100),
          const AuthGlowCircle(
              size: 260, color: Color(0x0DFF6B9D), bottom: 60, left: -120),
          const AuthGlowCircle(
              size: 120, color: Color(0x1A3D1D80), top: 180, left: 40),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: isWide
                      ? AuthCardLayout(child: _buildContent(context, auth))
                      : _buildContent(context, auth),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthState auth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthLogoMark()
              .animate()
              .scale(
                  begin: const Offset(0.7, 0.7),
                  duration: 500.ms,
                  curve: Curves.easeOutBack)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          const Text(
            'Welcome to MindScore',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: 80.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 8),

          const Text(
            'Discover your personality. Unlock your potential.',
            style: TextStyle(
              color: kAuthTextSecondary,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: 120.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 36),

          // Email
          AuthTextField(
            controller: _emailCtrl,
            hint: 'Email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          )
              .animate(delay: 160.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.08, end: 0),

          const SizedBox(height: 14),

          // Password
          AuthTextField(
            controller: _passwordCtrl,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscure,
            suffix: AuthEyeToggle(
              obscure: _obscure,
              onTap: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Min 6 characters';
              return null;
            },
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.08, end: 0),

          const SizedBox(height: 6),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _onForgotPassword,
              style: TextButton.styleFrom(
                foregroundColor: kAuthPurpleLight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
              child: const Text(
                'Forgot password?',
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ).animate(delay: 230.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 16),

          // Sign in
          AuthPrimaryButton(
            label: 'Sign in',
            isLoading: auth.isLoading,
            onTap: auth.isLoading ? null : _submit,
          )
              .animate(delay: 260.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.06, end: 0),

          const SizedBox(height: 24),

          const AuthOrDivider()
              .animate(delay: 300.ms)
              .fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          AuthGoogleButton(onTap: _onGoogleTap)
              .animate(delay: 340.ms)
              .fadeIn(duration: 300.ms),

          const SizedBox(height: 32),

          // Footer nav
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style:
                    TextStyle(color: kAuthTextSecondary, fontSize: 14),
              ),
              GestureDetector(
                onTap: () => context.go(AppRoutes.register),
                child: const Text(
                  'Sign up free',
                  style: TextStyle(
                    color: kAuthPurpleLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ).animate(delay: 380.ms).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }
}
