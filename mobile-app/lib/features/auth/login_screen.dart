import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/brand_logo.dart';
import '../../data/providers/auth_controller.dart';
import '../../data/repositories/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(_email.text.trim(), _password.text);
      // Router redirects to home on Authenticated.
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const BrandLogo(size: 64),
                const SizedBox(height: 32),
                Text('Welcome back', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Log in to keep your streak alive.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Email',
                  controller: _email,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Password',
                  controller: _password,
                  hint: '••••••••',
                  obscure: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: (v) => (v == null || v.length < 8)
                      ? 'At least 8 characters'
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(Routes.forgotPassword),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Log in',
                  loading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                AppOutlineButton(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded,
                  onPressed: () => _showError(
                      'Google Sign-In needs OAuth client setup (see README).'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New here?",
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    TextButton(
                      onPressed: () => context.push(Routes.signup),
                      child: const Text('Create an account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
