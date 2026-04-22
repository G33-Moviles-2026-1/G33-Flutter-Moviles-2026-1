import 'package:andespace/features/auth/presentation/controllers/auth_notifier.dart';
import '../controllers/my_bookings_notifier.dart';
import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/shared/widgets/auth_required_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/section_page_layout.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../controllers/my_bookings_state.dart';
import '../widgets/my_booking_card.dart';

class MyBookingsPage extends ConsumerWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (!authState.hasActiveSession) {
      return AuthRequiredScaffold(
        currentTab: AppTab.bookings,
        onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
        title: 'Log in to view your bookings',
        message: 'Sign in to access your active and recent bookings.',
      );
    }

    final state = ref.watch(myBookingsControllerProvider);
    final controller = ref.read(myBookingsControllerProvider.notifier);

    ref.listen<MyBookingsState>(myBookingsControllerProvider, (previous, next) {
      final nextError = next.errorMessage;
      final previousError = previous?.errorMessage;

      if (nextError != null && nextError != previousError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(nextError), duration: const Duration(seconds: 4),));
      }
    });

    return AppScaffold(
      currentTab: AppTab.bookings,
      onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
      body: SectionPageLayout(
        title: 'My Bookings',
        subtitle: 'Bookings created in the last 30 days',
        child: Builder(
          builder: (context) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.items.isEmpty) {
              return Center(
                child: Text(
                  'You have no recent bookings.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.load,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final booking = state.items[index];
                  final isDeleting = state.deletingIds.contains(booking.id);

                  return MyBookingCard(
                    booking: booking,
                    isDeleting: isDeleting,
                    onDeleteTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text('Delete booking?'),
                            content: const Text(
                              'This booking will disappear from your bookings list. Are you sure you want to continue?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, false);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, true);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed == true) {
                        await controller.deleteBooking(booking.id);
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
