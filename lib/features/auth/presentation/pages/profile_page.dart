import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/auth/domain/entities/user_status.dart';
import 'package:andespace/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
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
      setState(
        () => _passwordError = 'Password must be at least 8 characters.',
      );
      return;
    }

    setState(() {
      _passwordLoading = true;
      _passwordError = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .updatePassword(currentPassword: current, newPassword: newPw);
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
    final user = ref.watch(authControllerProvider).user;
    final currentStatus = user?.status ?? UserStatus.incognito;

    return AppScaffold(
      currentTab: AppTab.rooms,
      onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 720 ? 32.0 : 20.0;

            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                32,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ProfileHero(
                          username: user?.username,
                          status: currentStatus,
                          semester: user?.firstSemester,
                        ),
                        const SizedBox(height: 18),
                        _ProfileSection(
                          icon: Icons.badge_outlined,
                          title: 'Account',
                          subtitle: 'Change your username at any time.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
          Text(
            'Profile',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),

                              TextFormField(
                                controller: _usernameCtrl,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(30),
                                ],
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  hintText: 'Username',
                                  errorText: _usernameError,
                              
                                  floatingLabelStyle: theme.textTheme.bodySmall
                                      ?.copyWith(
                                        color: theme.colorScheme.secondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                          
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.62),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _ActionButton(
                                label: 'Update username',
                                icon: Icons.check,
                                loading: _usernameLoading,
                                onPressed: _submitUsername,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ProfileSection(
                          icon: Icons.wifi_tethering_outlined,
                          title: 'Availability',
                          subtitle:
                              'Your status helps friends understand when to reach you.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_statusError != null) ...[
                                _ErrorBanner(message: _statusError!),
                                const SizedBox(height: 12),
                              ],
                              if (_statusLoading)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: UserStatus.values.map((status) {
                                    return _StatusOption(
                                      status: status,
                                      selected: status == currentStatus,
                                      onTap: () => _submitStatus(status),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 12),
                              Text(
                                'Incognito hides you from friend notifications.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.58,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ProfileSection(
                          icon: Icons.lock_outline,
                          title: 'Security',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _PasswordField(
                                controller: _currentPwCtrl,
                                hint: 'Current password',
                                obscure: _obscureCurrent,
                                onToggle: () => setState(
                                  () => _obscureCurrent = !_obscureCurrent,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _PasswordField(
                                controller: _newPwCtrl,
                                hint: 'New password',
                                obscure: _obscureNew,
                                onToggle: () =>
                                    setState(() => _obscureNew = !_obscureNew),
                              ),
                              const SizedBox(height: 12),
                              _PasswordField(
                                controller: _confirmPwCtrl,
                                hint: 'Confirm new password',
                                obscure: _obscureConfirm,
                                onToggle: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                                errorText: _passwordError,
                              ),
                              const SizedBox(height: 12),
                              _ActionButton(
                                label: 'Change password',
                                icon: Icons.lock_reset,
                                loading: _passwordLoading,
                                onPressed: _submitPassword,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.username,
    required this.status,
    required this.semester,
  });

  final String? username;
  final UserStatus status;
  final String? semester;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;
    final colorScheme = theme.colorScheme;
    final displayName = username?.trim().isNotEmpty == true
        ? username!.trim()
        : 'Username';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: brand.headerBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.24 : 0.08,
            ),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              shape: BoxShape.circle,
              border: Border.all(
                color: brand.headerForeground.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(Icons.person, color: colorScheme.onSecondary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: brand.headerForeground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoPill(icon: _statusIcon(status), label: status.label),
                    if (semester?.trim().isNotEmpty == true)
                      _InfoPill(
                        icon: Icons.school_outlined,
                        label: semester!.trim(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.secondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.colorScheme.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.58,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final UserStatus status;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foreground = selected
        ? colorScheme.onSecondary
        : colorScheme.onSurface.withValues(alpha: 0.82);

    return Material(
      color: selected ? colorScheme.secondary : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? colorScheme.secondary
                  : theme.dividerColor.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_statusIcon(status), size: 16, color: foreground),
              const SizedBox(width: 7),
              Text(
                status.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 19),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
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
    final theme = Theme.of(context);

    final fieldTextColor = theme.colorScheme.onSurface;
    final subtleTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: theme.textTheme.bodySmall?.copyWith(
        color: fieldTextColor,
        fontSize: 13,
      ),
      inputFormatters: [LengthLimitingTextInputFormatter(60)],
      decoration: InputDecoration(
        labelText: hint,
        hintText: hint,
        errorText: errorText,
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          color: subtleTextColor,
          fontSize: 12,
        ),
        floatingLabelStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: theme.textTheme.bodySmall?.copyWith(
          color: subtleTextColor,
          fontSize: 12,
        ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(Icons.lock_outline, size: 20, color: subtleTextColor),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            size: 20,
            color: subtleTextColor,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

IconData _statusIcon(UserStatus status) {
  return switch (status) {
    UserStatus.incognito => Icons.visibility_off_outlined,
    UserStatus.busy => Icons.do_not_disturb_on_outlined,
    UserStatus.exercising => Icons.fitness_center_outlined,
    UserStatus.free => Icons.check_circle_outline,
    UserStatus.hangingOut => Icons.groups_outlined,
    UserStatus.atHome => Icons.home_outlined,
    UserStatus.lunching => Icons.restaurant_outlined,
  };
}
