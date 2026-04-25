import 'package:andespace/features/auth/presentation/notifiers/auth_notifier.dart';
import '../controllers/create_booking_notifier.dart';
import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme_extension.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/auth_required_scaffold.dart';
import '../../../rooms/domain/entities/room_search.dart';
import '../providers/bookings_providers.dart';
import '../widgets/booking_time_picker_row.dart';
import '../widgets/purpose_selector.dart';

class CreateBookingPage extends ConsumerWidget {
  const CreateBookingPage({super.key, required this.room});

  final RoomSearchItem room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isLoggedIn = authState.hasActiveSession;

    if (!isLoggedIn) {
      return AuthRequiredScaffold(
        currentTab: AppTab.bookings,
        onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
        title: 'Log in to book rooms',
        message: 'Sign in to create and manage room bookings.',
      );
    }

    final state = ref.watch(createBookingControllerProvider(room));
    final controller = ref.read(createBookingControllerProvider(room).notifier);
    final bookingDateBounds = ref.read(getBookingDateBoundsUseCaseProvider)();
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>();

    ref.listen(createBookingControllerProvider(room), (previous, next) {
      final createdNow = previous?.created == null && next.created != null;
      if (createdNow) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking created successfully.'),
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context, next.created);
        return;
      }

      final queuedNow = previous?.isPendingSync != true && next.isPendingSync;
      if (queuedNow) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Booking queued — not confirmed yet. If you close the app before connection is restored, this action will be lost.',
            ),
            duration: Duration(seconds: 7),
          ),
        );
        Navigator.pop(context, null);
        return;
      }

      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;

      if (nextError != null && nextError != previousError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(nextError),
              duration: const Duration(seconds: 4),
            ),
          );
        return;
      }

      final previousAvailabilityError = previous?.availabilityErrorMessage;
      final nextAvailabilityError = next.availabilityErrorMessage;

      if (nextAvailabilityError != null &&
          nextAvailabilityError != previousAvailabilityError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(nextAvailabilityError),
              duration: const Duration(seconds: 4),
            ),
          );
      }
    });

    return AppScaffold(
      currentTab: AppTab.bookings,
      onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book ${room.roomId}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 32,
                        color: theme.colorScheme.onSurface,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      room.buildingName ?? room.buildingCode,
                      style: theme.textTheme.bodyLarge,
                      softWrap: true,
                    ),
                    const SizedBox(height: 30),
                    Text('Pick a time', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 10),
                    if (state.isLoadingAvailability) ...[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(),
                      ),
                    ],
                    BookingTimePickerRow(
                      selectedDate: state.selectedDate,
                      availabilities: state.availableTimeRanges,
                      selectedTimeRange: state.selectedTimeRange,
                      onPickDate: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: state.selectedDate,
                          firstDate: bookingDateBounds.firstBookableDate,
                          lastDate: bookingDateBounds.lastBookableDate,
                          useRootNavigator: true,
                          selectableDayPredicate: (d) {
                            final normalized = DateTime(d.year, d.month, d.day);
                            return !normalized.isBefore(
                                  bookingDateBounds.firstBookableDate,
                                ) &&
                                !normalized.isAfter(
                                  bookingDateBounds.lastBookableDate,
                                );
                          },
                        );

                        if (picked == null) return;
                        await controller.setDate(picked);
                      },
                      onSelectTimeRange: controller.setTimeRange,
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'Select the purpose',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    PurposeSelector(
                      selected: state.selectedPurpose,
                      onChanged: controller.setPurpose,
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isSubmitting ||
                          state.isLoadingAvailability ||
                          state.selectedTimeRange == null
                      ? null
                      : controller.submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        brand?.accentYellow ?? theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: theme.brightness == Brightness.light
                          ? BorderSide(
                              color: theme.colorScheme.onSurface,
                              width: 1.4,
                            )
                          : BorderSide.none,
                    ),
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: state.isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onSecondary,
                          ),
                        )
                      : const Text('Book'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}