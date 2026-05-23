import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:andespace/features/friendships/domain/entities/friendship_request.dart';
import 'package:andespace/features/friendships/presentation/controllers/friendships_state.dart';
import 'package:andespace/features/friendships/presentation/providers/friendships_providers.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:andespace/shared/widgets/auth_required_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final colorScheme = theme.colorScheme;

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
      body: RefreshIndicator(
        onRefresh: notifier.loadOnlineSections,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 34),
              ),
            ),
            Text(
              'Add friends',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            Material(
              color: theme.cardColor,
              elevation: 0,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.18),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: notifier.setAddFriendInput,
                  decoration: const InputDecoration(
                    hintText: 'Search by username',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => notifier.sendFriendRequest(_controller.text),
                child: const Text(
                  'Send friend request',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 22),
            _SectionTitle('Pending requests:'),
            _PendingRequestsBox(state: state, notifier: notifier),
            const SizedBox(height: 18),
            _SectionTitle('People you might know:'),
            _SuggestionsBox(state: state, notifier: notifier),
          ],
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
        fontSize: 20,
      ),
    );
  }
}

class _PendingRequestsBox extends StatelessWidget {
  const _PendingRequestsBox({required this.state, required this.notifier});

  final FriendshipsState state;
  final dynamic notifier;

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

    if (state.pendingRequests.isEmpty) {
      return const _InfoBox(message: 'No pending requests.');
    }

    return _BoxContainer(
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
  const _SuggestionsBox({required this.state, required this.notifier});

  final FriendshipsState state;
  final dynamic notifier;

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

    if (state.suggestions.isEmpty) {
      return const _InfoBox(message: 'No suggestions available right now.');
    }

    return _BoxContainer(
      child: Column(
        children: [
          for (final username in state.suggestions)
            _SuggestionRow(
              username: username,
              isPending: state.pendingFriendUsernames.contains(username),
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
    final colorScheme = Theme.of(context).colorScheme;

    return _RowCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              request.username,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (request.isIncoming) ...[
            OutlinedButton(
              onPressed: onDeclineOrCancel,
              child: const Text('Decline'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
              ),
              onPressed: onAccept,
              child: const Text('Accept'),
            ),
          ] else ...[
            OutlinedButton(onPressed: null, child: const Text('Pending')),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
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
    final colorScheme = Theme.of(context).colorScheme;

    return _RowCard(
      child: Row(
        children: [
          Expanded(
            child: Text(username, style: Theme.of(context).textTheme.bodyLarge),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
            ),
            onPressed: isPending ? null : onAdd,
            child: Text(isPending ? 'Sending...' : 'Add friend +'),
          ),
        ],
      ),
    );
  }
}

class _BoxContainer extends StatelessWidget {
  const _BoxContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
    return _BoxContainer(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox();

  @override
  Widget build(BuildContext context) {
    return const _BoxContainer(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
