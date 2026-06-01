import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:andespace/features/friendships/domain/entities/friendship_request.dart';
import 'package:andespace/features/friendships/presentation/notifiers/friendships_notifier.dart';
import 'package:andespace/features/friendships/presentation/notifiers/friendships_state.dart';
import 'package:andespace/features/friendships/presentation/providers/friendships_providers.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:andespace/shared/widgets/auth_required_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddFriendsPage extends ConsumerStatefulWidget {
  const AddFriendsPage({super.key});

  @override
  ConsumerState<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends ConsumerState<AddFriendsPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    final cachedInput = ref.read(friendshipsControllerProvider).addFriendInput;
    _controller = TextEditingController(text: cachedInput);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(friendshipsControllerProvider.notifier).loadOnlineSections();
    });
  }

  @override
  void dispose() {
    ref
        .read(friendshipsControllerProvider.notifier)
        .setAddFriendInput(_controller.text);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    if (!authState.hasActiveSession) {
      return AuthRequiredScaffold(
        currentTab: AppTab.favorites,
        onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
        title: 'Log in to add friends',
        message: 'Sign in to send requests and see friend suggestions.',
      );
    }

    final state = ref.watch(friendshipsControllerProvider);
    final notifier = ref.read(friendshipsControllerProvider.notifier);
    final theme = Theme.of(context);

    ref.listen<FriendshipsState>(friendshipsControllerProvider, (
      previous,
      next,
    ) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;

      if (nextError != null && nextError != previousError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(nextError)));
      }
    });

    return AppScaffold(
      currentTab: AppTab.favorites,
      onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
      body: Container(
        color: _pageBackground(context),
        child: RefreshIndicator(
          onRefresh: notifier.loadOnlineSections,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              SizedBox(
                height: 58,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: -12,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          size: 34,
                          color: _primaryIconColor(context),
                        ),
                      ),
                    ),
                    Text(
                      'Add friends',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 34,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SearchUsernameField(
                controller: _controller,
                onChanged: notifier.setAddFriendInput,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: _mainYellowButtonStyle(context),
                  onPressed: () async {
                    final sent = await notifier.sendFriendRequest(
                      _controller.text,
                    );

                    if (sent && mounted) {
                      _controller.clear();
                    }
                  },
                  child: const Text(
                    'Send friend request',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const _SectionTitle('Pending requests:'),
              _PendingRequestsBox(state: state, notifier: notifier),
              const SizedBox(height: 18),
              const _SectionTitle('People you might know:'),
              _SuggestionsBox(state: state, notifier: notifier),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchUsernameField extends StatelessWidget {
  const _SearchUsernameField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: _cardBackground(context),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(10),
      child: TextField(
        controller: controller,
        maxLength: 25,
        maxLengthEnforcement: services.MaxLengthEnforcement.enforced,
        inputFormatters: [
          services.LengthLimitingTextInputFormatter(25),
          services.FilteringTextInputFormatter.allow(
            RegExp(r'[a-zA-Z0-9._-]'),
          ),
          services.TextInputFormatter.withFunction((oldValue, newValue) {
            final lowerText = newValue.text.toLowerCase();

            return TextEditingValue(
              text: lowerText,
              selection: TextSelection.collapsed(offset: lowerText.length),
            );
          }),
        ],
        onChanged: onChanged,
        style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search by username',
          counterText: '',
          filled: true,
          fillColor: _cardBackground(context),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              'assets/icons/searchusername.svg',
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                _primaryIconColor(context),
                BlendMode.srcIn,
              ),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _borderColor(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: _accentColor(context),
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
    );
  }
}

class _PendingRequestsBox extends StatelessWidget {
  const _PendingRequestsBox({
    required this.state,
    required this.notifier,
  });

  final FriendshipsState state;
  final FriendshipsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (state.onlineSectionsOffline) {
      return const _InfoBox(
        message: 'No internet connection. Pending requests cannot be loaded.',
      );
    }

    if (state.isOnlineSectionsLoading && state.pendingRequests.isEmpty) {
      return const _LoadingBox();
    }

    if (state.requestsErrorMessage != null &&
        state.requestsErrorMessage!.trim().isNotEmpty) {
      return _InfoBox(message: state.requestsErrorMessage!);
    }

    if (state.pendingRequests.isEmpty) {
      return const _InfoBox(message: 'No pending requests.');
    }

    return _SectionBox(
      child: Column(
        children: [
          for (final request in state.pendingRequests)
            _RequestRow(
              request: request,
              onAccept: () => notifier.acceptRequest(request.username),
              onDeclineOrCancel: () =>
                  notifier.declineOrCancelRequest(request.username),
            ),
        ],
      ),
    );
  }
}

class _SuggestionsBox extends StatelessWidget {
  const _SuggestionsBox({
    required this.state,
    required this.notifier,
  });

  final FriendshipsState state;
  final FriendshipsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (state.onlineSectionsOffline) {
      return const _InfoBox(
        message: 'No internet connection. Friend suggestions cannot be loaded.',
      );
    }

    if (state.isOnlineSectionsLoading && state.suggestions.isEmpty) {
      return const _LoadingBox();
    }

    if (state.suggestionsErrorMessage != null) {
      return _InfoBox(message: state.suggestionsErrorMessage!);
    }

    if (state.hasLoadedOnlineSections && state.suggestions.isEmpty) {
      return const _InfoBox(message: 'No suggestions available right now.');
    }

    return _SectionBox(
      child: Column(
        children: [
          for (final username in state.suggestions)
            _SuggestionRow(
              username: username,
              isPending: state.pendingFriendUsernames
                  .map((item) => item.toLowerCase())
                  .contains(username.toLowerCase()),
              onAdd: () => notifier.sendFriendRequest(username),
            ),
        ],
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.request,
    required this.onAccept,
    required this.onDeclineOrCancel,
  });

  final FriendshipRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDeclineOrCancel;

  @override
  Widget build(BuildContext context) {
    return _ListRowCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              request.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          if (request.isIncoming) ...[
            OutlinedButton(
              style: _compactOutlinedButtonStyle(context),
              onPressed: onDeclineOrCancel,
              child: const Text('Decline'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: _compactElevatedButtonStyle(context),
              onPressed: onAccept,
              child: const Text('Accept'),
            ),
          ] else ...[
            OutlinedButton(
              style: _compactOutlinedButtonStyle(context),
              onPressed: null,
              child: const Text('Pending'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: _compactElevatedButtonStyle(
                context,
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: onDeclineOrCancel,
              child: const Text('Cancel'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    required this.username,
    required this.isPending,
    required this.onAdd,
  });

  final String username;
  final bool isPending;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return _ListRowCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: _compactElevatedButtonStyle(context),
            onPressed: isPending ? null : onAdd,
            child: Text(isPending ? 'Sending...' : 'Add friend +'),
          ),
        ],
      ),
    );
  }
}

class _SectionBox extends StatelessWidget {
  const _SectionBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 7),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _sectionBackground(context),
        border: Border.all(color: _sectionBorderColor(context)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: child,
    );
  }
}

class _ListRowCard extends StatelessWidget {
  const _ListRowCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        child: child,
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _SectionBox(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox();

  @override
  Widget build(BuildContext context) {
    return const _SectionBox(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

Color _pageBackground(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return isDark ? theme.scaffoldBackgroundColor : Colors.white;
}

Color _cardBackground(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return isDark ? const Color(0xFF1A1D22) : Colors.white;
}

Color _sectionBackground(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return isDark ? const Color(0xFF15181D) : const Color(0xFFFFFDEB);
}

Color _accentColor(BuildContext context) {
  final brand = Theme.of(context).extension<BrandColors>()!;
  return brand.accentYellow;
}

Color _primaryIconColor(BuildContext context) {
  final theme = Theme.of(context);
  final brand = theme.extension<BrandColors>()!;
  final isDark = theme.brightness == Brightness.dark;

  return isDark ? brand.accentYellow : Colors.black;
}

Color _borderColor(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return isDark
      ? Colors.white.withValues(alpha: 0.10)
      : Colors.black.withValues(alpha: 0.08);
}

Color _sectionBorderColor(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return isDark
      ? Colors.white.withValues(alpha: 0.14)
      : Colors.black.withValues(alpha: 0.78);
}

ButtonStyle _mainYellowButtonStyle(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  return ElevatedButton.styleFrom(
    backgroundColor: colorScheme.secondary,
    foregroundColor: colorScheme.onSecondary,
    elevation: 4,
    shadowColor: Colors.black.withValues(alpha: 0.28),
    minimumSize: const Size(0, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Colors.black, width: 1.1),
    ),
  );
}

ButtonStyle _compactElevatedButtonStyle(
  BuildContext context, {
  Color? backgroundColor,
  Color? foregroundColor,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return ElevatedButton.styleFrom(
    backgroundColor: backgroundColor ?? colorScheme.secondary,
    foregroundColor: foregroundColor ?? colorScheme.onSecondary,
    minimumSize: const Size(0, 40),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.transparent
            : Colors.black,
        width: 1,
      ),
    ),
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w800,
    ),
  );
}

ButtonStyle _compactOutlinedButtonStyle(BuildContext context) {
  return OutlinedButton.styleFrom(
    foregroundColor: Theme.of(context).colorScheme.onSurface,
    minimumSize: const Size(0, 40),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    side: BorderSide(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.24)
          : Colors.black,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w800,
    ),
  );
}