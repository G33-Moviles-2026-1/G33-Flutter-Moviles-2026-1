import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/features/auth/domain/entities/user_status.dart';
import 'package:andespace/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _usernameCtrl = TextEditingController();
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _usernameLoading = false;
  bool _statusLoading = false;
  bool _passwordLoading = false;

  String? _usernameError;
  String? _statusError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _usernameCtrl.text = user?.username ?? '';
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitUsername() async {
    final username = _usernameCtrl.text.trim();
    if (username.isEmpty) {
      setState(() => _usernameError = 'Username cannot be empty.');
      return;
    }
    setState(() {
      _usernameLoading = true;
      _usernameError = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).updateUsername(username);
      if (mounted) _showSnackBar('Username updated.');
    } catch (e) {
      if (mounted) setState(() => _usernameError = _mapError(e));
    } finally {
      if (mounted) setState(() => _usernameLoading = false);
    }
  }

  Future<void> _submitStatus(UserStatus status) async {
    setState(() {
      _statusLoading = true;
      _statusError = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .updateStatus(status.backendKey);
      if (mounted) _showSnackBar('Status updated.');
    } catch (e) {
      if (mounted) setState(() => _statusError = _mapError(e));
    } finally {
      if (mounted) setState(() => _statusLoading = false);
    }
  }

  Future<void> _submitPassword() async {
    final current = _currentPwCtrl.text.trim();
    final newPw = _newPwCtrl.text.trim();
    final confirm = _confirmPwCtrl.text.trim();

    if (current.isEmpty || newPw.isEmpty || confirm.isEmpty) {
      setState(() => _passwordError = 'Fill in all password fields.');
      return;
    }
    if (newPw != confirm) {
      setState(() => _passwordError = 'New passwords do not match.');
      return;
    }
    if (newPw.length < 8) {
      setState(() => _passwordError = 'Password must be at least 8 characters.');
      return;
    }

    setState(() {
      _passwordLoading = true;
      _passwordError = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).updatePassword(
            currentPassword: current,
            newPassword: newPw,
          );
      if (mounted) {
        _currentPwCtrl.clear();
        _newPwCtrl.clear();
        _confirmPwCtrl.clear();
        _showSnackBar('Password updated.');
      }
    } catch (e) {
      if (mounted) setState(() => _passwordError = _mapError(e));
    } finally {
      if (mounted) setState(() => _passwordLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _mapError(Object e) => DioErrorMapper.map(
        e,
        fallback: 'Something went wrong. Please try again.',
        onBadResponse: (code, detail) {
          if (detail != null && detail.trim().isNotEmpty) return detail.trim();
          if (code == 400) return 'Invalid request. Check your input.';
          if (code == 401) return 'Current password is incorrect.';
          return 'Something went wrong. Please try again.';
        },
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;
    final user = ref.watch(authControllerProvider).user;
    final currentStatus = user?.status ?? UserStatus.incognito;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: brand.headerBackground,
        foregroundColor: brand.headerForeground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader(title: 'Username'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _usernameCtrl,
            inputFormatters: [LengthLimitingTextInputFormatter(30)],
            decoration: InputDecoration(
              hintText: 'Username',
              errorText: _usernameError,
            ),
          ),
          const SizedBox(height: 12),
          _ActionButton(
            label: 'Update Username',
            loading: _usernameLoading,
            onPressed: _submitUsername,
          ),

          const SizedBox(height: 28),
          _SectionHeader(title: 'Status'),
          const SizedBox(height: 4),
          Text(
            'Incognito hides you from friend notifications.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          if (_statusError != null) ...[
            Text(
              _statusError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (_statusLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: UserStatus.values.map((s) {
                final selected = s == currentStatus;
                return ChoiceChip(
                  label: Text(s.label),
                  selected: selected,
                  onSelected: (_) => _submitStatus(s),
                );
              }).toList(),
            ),

          const SizedBox(height: 28),
          _SectionHeader(title: 'Change Password'),
          const SizedBox(height: 12),
          _PasswordField(
            controller: _currentPwCtrl,
            hint: 'Current password',
            obscure: _obscureCurrent,
            onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
          ),
          const SizedBox(height: 12),
          _PasswordField(
            controller: _newPwCtrl,
            hint: 'New password',
            obscure: _obscureNew,
            onToggle: () => setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 12),
          _PasswordField(
            controller: _confirmPwCtrl,
            hint: 'Confirm new password',
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            errorText: _passwordError,
          ),
          const SizedBox(height: 12),
          _ActionButton(
            label: 'Change Password',
            loading: _passwordLoading,
            onPressed: _submitPassword,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    this.errorText,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      inputFormatters: [LengthLimitingTextInputFormatter(60)],
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
