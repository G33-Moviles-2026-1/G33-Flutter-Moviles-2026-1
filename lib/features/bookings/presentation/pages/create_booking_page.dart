import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../rooms/domain/entities/room_detail.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_footer.dart';
import '../../../../shared/theme/theme.dart';

import '../../data/repositories/bookings_repository_impl.dart';
import '../../domain/usecases/create_booking.dart';
import '../cubit/create_booking_cubit.dart';
import '../cubit/create_booking_state.dart';

import '../widgets/booking_time_picker_row.dart';
import '../widgets/purpose_selector.dart';
import '../widgets/people_picker.dart';

class CreateBookingPage extends StatelessWidget {
  const CreateBookingPage({
    super.key,
    required this.roomDetail,
  });

  final RoomDetail roomDetail;

  @override
  Widget build(BuildContext context) {
    // For now: instantiate usecase/repo locally (backend tomorrow).
    final repo = BookingsRepositoryImpl();
    final usecase = CreateBooking(repo);

    return BlocProvider(
      create: (_) => CreateBookingCubit(roomDetail: roomDetail, createBooking: usecase),
      child: const _CreateBookingView(),
    );
  }
}

class _CreateBookingView extends StatelessWidget {
  const _CreateBookingView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateBookingCubit>();

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
            title: 'Booking',
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cubit.roomDetail.id,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 32,
                          color: AppColors.black,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cubit.roomDetail.buildingName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 20),

                  Text('Pick a time', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 10),

                  BookingTimePickerRow(
                    selectedDate: state.selectedDate,
                    availabilities: avail,
                    selectedTimeRange: state.selectedTimeRange,
                    onPickDate: () async {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final last = today.add(const Duration(days: 7));

                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.selectedDate,
                        firstDate: today,
                        lastDate: last,
                        selectableDayPredicate: (d) {
                          final nd = DateTime(d.year, d.month, d.day);
                          return !nd.isBefore(today) && !nd.isAfter(last);
                        },
                      );

                      if (picked != null) cubit.setDate(picked);
                    },
                    onSelectTimeRange: cubit.setTimeRange,
                  ),

                  const SizedBox(height: 18),

                  Text('Select the purpose', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  PurposeSelector(
                    selected: state.selectedPurpose,
                    onChanged: cubit.setPurpose,
                  ),

                  const SizedBox(height: 18),

                  Text('Note how many people', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  PeoplePicker(
                    value: state.peopleCount,
                    min: 1,
                    max: cubit.roomDetail.capacity,
                    onChanged: cubit.setPeopleCount,
                  ),

                  const SizedBox(height: 22),

                  if (state.errorMessage != null) ...[
                    Text(
                      state.errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isSubmitting ? null : cubit.submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentYellow,
                        foregroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.black, width: 1.4),
                        ),
                        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Book'),
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