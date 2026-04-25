import 'package:andespace/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/auth_notifier.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_page_layout.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_submit_button.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _carnetCtrl = TextEditingController();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(() => setState(() {}));
    _confirmPasswordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _carnetCtrl.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  String _extractFirst5Digits(String input) {
    final onlyDigits = input.replaceAll(RegExp(r'[^0-9]'), '');
    return onlyDigits.substring(0, 5);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final first5Digits = _extractFirst5Digits(_carnetCtrl.text.trim());

    await ref.read(authControllerProvider.notifier).signup(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          firstSemester: first5Digits,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }

      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    final state = ref.watch(authControllerProvider);

    return AuthPageLayout(
      title: 'Sign Up',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailCtrl,
              inputFormatters: [
                LengthLimitingTextInputFormatter(35),
              ],
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Uniandes Mail',
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) {
                  return 'Enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email) ||
                    !email.endsWith('@uniandes.edu.co') ||
                    email.length > 35) {
                  return 'Enter a valid Uniandes email';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            AuthPasswordField(
              controller: _passwordCtrl,
              focusNode: _passwordFocusNode,
              obscureText: _obscurePassword,
              hintText: 'Password',
              onToggleVisibility: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              validator: (value) {
                final password = value?.trim() ?? '';
                if (password.isEmpty) {
                  return 'Enter your password';
                }
                if (password.length < 6 || password.length > 20) {
                  return 'The password must have between 6 and 20 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            AuthPasswordField(
              controller: _confirmPasswordCtrl,
              focusNode: _confirmPasswordFocusNode,
              obscureText: _obscureConfirmPassword,
              hintText: 'Repeat Password',
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: (value) {
                final confirmPassword = value?.trim() ?? '';
                if (confirmPassword.isEmpty) {
                  return 'Repeat your password';
                }
                if (confirmPassword != _passwordCtrl.text.trim()) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _carnetCtrl,
              inputFormatters: [
                LengthLimitingTextInputFormatter(9),
                FilteringTextInputFormatter.digitsOnly,
              ],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Student Code',
              ),
              validator: (value) {
                final raw = value?.trim() ?? '';
                final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');

                if (digitsOnly.isEmpty) {
                  return 'Enter your student code';
                }

                if (digitsOnly.length != 9) {
                  return 'The student code must have 9 digits';
                }

                return null;
              },
            ),
            const SizedBox(height: 28),
            AuthSubmitButton(
              isLoading: state.isLoading,
              label: 'Save',
              onPressed: _submit,
            ),
            const SizedBox(height: 30),
            AuthFooterLink(
              prefixText: 'If you have an account, ',
              actionText: 'log in',
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.login,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}