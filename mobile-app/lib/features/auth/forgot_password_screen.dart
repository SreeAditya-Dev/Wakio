import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/dio_client.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _State();
}

class _State extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(dioProvider)
          .post('/auth/forgot-password', data: {'email': _email.text.trim()});
    } catch (_) {
      /* endpoint always returns 202 to avoid account enumeration */
    } finally {
      if (mounted) setState(() {
            _loading = false;
            _sent = true;
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _sent
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mark_email_read_outlined,
                        size: 72, color: Color(0xFF22C55E)),
                    const SizedBox(height: 24),
                    Text('Check your inbox',
                        style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'If an account exists for ${_email.text.trim()}, a reset link is on its way.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                        label: 'Back to login',
                        onPressed: () => context.pop()),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Forgot your password?',
                          style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                          'Enter your email and we\'ll send you a reset link.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 28),
                      AppTextField(
                        label: 'Email',
                        controller: _email,
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline_rounded,
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                          label: 'Send reset link',
                          loading: _loading,
                          onPressed: _submit),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
