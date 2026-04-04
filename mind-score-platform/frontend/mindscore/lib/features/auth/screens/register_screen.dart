import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authProvider.notifier)
        .register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passwordCtrl.text);
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
              size: 280, color: Color(0x1AA67CF0), top: -80, left: -100),
          const AuthGlowCircle(
              size: 220, color: Color(0x0DFF6B9D), bottom: 80, right: -80),
          const AuthGlowCircle(
              size: 100, color: Color(0x1A6B35C8), top: 260, right: 60),
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
            'Create Your Account',
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
            'Join thousands discovering their potential.',
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

          // Full Name
          AuthTextField(
            controller: _nameCtrl,
            hint: 'Full Name',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Name is required';
              return null;
            },
          )
              .animate(delay: 160.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.08, end: 0),

          const SizedBox(height: 14),

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
              .animate(delay: 200.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.08, end: 0),

          const SizedBox(height: 14),

          // Password
          AuthTextField(
            controller: _passwordCtrl,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffix: AuthEyeToggle(
              obscure: _obscurePassword,
              onTap: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Min 6 characters';
              return null;
            },
          )
              .animate(delay: 240.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.08, end: 0),

          const SizedBox(height: 14),

          // Confirm Password
          AuthTextField(
            controller: _confirmCtrl,
            hint: 'Confirm Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            suffix: AuthEyeToggle(
              obscure: _obscureConfirm,
              onTap: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm password';
              if (v != _passwordCtrl.text) return 'Passwords do not match';
              return null;
            },
          )
              .animate(delay: 280.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.08, end: 0),

          const SizedBox(height: 8),

          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'At least 6 characters',
              style: TextStyle(color: kAuthMuted, fontSize: 12),
            ),
          ).animate(delay: 300.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // Create Account button
          AuthPrimaryButton(
            label: 'Create Account',
            isLoading: auth.isLoading,
            onTap: auth.isLoading ? null : _submit,
          )
              .animate(delay: 320.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.06, end: 0),

          const SizedBox(height: 18),

          const Text(
            'By creating an account you agree to our\nTerms of Service and Privacy Policy.',
            style: TextStyle(
              color: kAuthMuted,
              fontSize: 12,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 360.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 28),

          // Footer nav
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style:
                    TextStyle(color: kAuthTextSecondary, fontSize: 14),
              ),
              GestureDetector(
                onTap: () => context.go(AppRoutes.login),
                child: const Text(
                  'Sign in',
                  style: TextStyle(
                    color: kAuthPurpleLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }
}
