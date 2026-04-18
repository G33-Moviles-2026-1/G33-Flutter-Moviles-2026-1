import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_notifier.dart';

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

    _passwordFocusNode.addListener(() {
      setState(() {});
    });

    _confirmPasswordFocusNode.addListener(() {
      setState(() {});
    });
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return AppScaffold(
      currentTab: AppTab.rooms,
      onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 28),
                Text(
                  'Sign Up',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 36),
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
                TextFormField(
                  controller: _passwordCtrl,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                  focusNode: _passwordFocusNode,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: _passwordFocusNode.hasFocus
                        ? IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          )
                        : null,
                  ),
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
                TextFormField(
                  controller: _confirmPasswordCtrl,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                  focusNode: _confirmPasswordFocusNode,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Repeat Password',
                    suffixIcon: _confirmPasswordFocusNode.hasFocus
                        ? IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          )
                        : null,
                  ),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () async {
                            FocusScope.of(context).unfocus();

                            if (!_formKey.currentState!.validate()) return;

                            final first5Digits =
                                _extractFirst5Digits(_carnetCtrl.text.trim());

                            await ref
                                .read(authControllerProvider.notifier)
                                .signup(
                                  email: _emailCtrl.text.trim(),
                                  password: _passwordCtrl.text.trim(),
                                  firstSemester: first5Digits,
                                );
                          },
                    child: state.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text('Save'),
                  ),
                ),
                const SizedBox(height: 30),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'If you have an account, ',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'log in',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
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