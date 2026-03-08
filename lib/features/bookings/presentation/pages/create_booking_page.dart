import 'package:andespace/core/navigation/app_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../rooms/domain/entities/room_detail.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/theme/app_theme_extension.dart';

import '../../data/repositories/bookings_repository_impl.dart';
import '../../domain/usecases/create_booking.dart';
import '../cubit/create_booking_cubit.dart';
import '../cubit/create_booking_state.dart';

import '../widgets/booking_time_picker_row.dart';
import '../widgets/purpose_selector.dart';
import '../widgets/people_count_field.dart';

class CreateBookingPage extends StatelessWidget {
  const CreateBookingPage({super.key, required this.roomDetail});

  final RoomDetail roomDetail;

  @override
  Widget build(BuildContext context) {
    // For now: instantiate usecase/repo locally (backend tomorrow).
    final repo = BookingsRepositoryImpl();
    final usecase = CreateBooking(repo);

    return BlocProvider(
      create: (_) =>
          CreateBookingCubit(roomDetail: roomDetail, createBooking: usecase),
      child: const _CreateBookingView(),
    );
  }
}

class _CreateBookingView extends StatelessWidget {
  const _CreateBookingView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateBookingCubit>();
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>();

    return BlocListener<CreateBookingCubit, CreateBookingState>(
      listenWhen: (prev, next) => prev.created == null && next.created != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking created (pending).')),
        );
        Navigator.pop(context); // return to detail for now
      },
      child: BlocBuilder<CreateBookingCubit, CreateBookingState>(
        builder: (context, state) {
          final avail = cubit.currentAvailabilities();

          return AppScaffold(
            currentTab: AppTab.bookings,
            onTabSelected: (_) {},
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
                            'Book ${cubit.roomDetail.id}',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 32,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Pick a time',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 10),
                          BookingTimePickerRow(
                            selectedDate: state.selectedDate,
                            availabilities: avail,
                            selectedTimeRange: state.selectedTimeRange,
                            onPickDate: () async {
                              final now = DateTime.now();
                              final today = DateTime(
                                now.year,
                                now.month,
                                now.day,
                              );
                              final last = today.add(const Duration(days: 7));

                              final picked = await showDatePicker(
                                context: context,
                                initialDate: state.selectedDate,
                                firstDate: today,
                                lastDate: last,
                                selectableDayPredicate: (d) {
                                  final nd = DateTime(d.year, d.month, d.day);
                                  return !nd.isBefore(today) &&
                                      !nd.isAfter(last);
                                },
                              );

                              if (picked != null) cubit.setDate(picked);
                            },
                            onSelectTimeRange: cubit.setTimeRange,
                          ),
                          const SizedBox(height: 25),
                          Text(
                            'Select the purpose',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          PurposeSelector(
                            selected: state.selectedPurpose,
                            onChanged: cubit.setPurpose,
                          ),
                          const SizedBox(height: 25),
                          Text(
                            'Note how many people',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          PeopleCountField(
                            value: state.peopleCount,
                            max: cubit.roomDetail.capacity,
                            onChanged: cubit.setPeopleCount,
                          ),
                          const SizedBox(height: 22),
                          if (state.errorMessage != null) ...[
                            Text(
                              state.errorMessage!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isSubmitting ? null : cubit.submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              brand?.accentYellow ?? theme.colorScheme.secondary,
                          foregroundColor: theme.colorScheme.onSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.onSurface,
                              width: 1.4,
                            ),
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
        },
      ),
    );
  }
}
