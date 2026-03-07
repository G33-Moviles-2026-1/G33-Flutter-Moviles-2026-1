import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/theme/theme.dart';
import '../../domain/entities/room_detail.dart';
import '../cubit/room_detail_cubit.dart';
import '../cubit/room_detail_state.dart';

class RoomDetailBody extends StatefulWidget {
  const RoomDetailBody({super.key});

  @override
  State<RoomDetailBody> createState() => _RoomDetailBodyState();
}

class _RoomDetailBodyState extends State<RoomDetailBody> {
  DateTime selectedDate = DateTime.now();

  void _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accentYellow,
              onPrimary: AppColors.black,
              surface: AppColors.white,
              onSurface: AppColors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.black,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomDetailCubit, RoomDetailState>(
      builder: (context, state) {
        if (state is RoomDetailLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RoomDetailError) {
          return Center(child: Text(state.message));
        }

        if (state is RoomDetailLoaded) {
          return _buildContent(state.roomDetail);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildContent(RoomDetail room) {
    final t = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.id, style: t.textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text("Building: ${room.buildingName}",
                        style: t.textTheme.bodyMedium),
                    Text("Capacity: ${room.capacity}",
                        style: t.textTheme.bodyMedium),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.report),
                onPressed: () {},
              ),

              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// DATE SELECTOR
          Center(
            child: GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.black),
                ),
                child: Row(
                  children: [
                    Text(
                      
                      _formatDate(selectedDate),
                      style: t.textTheme.bodyLarge,
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// AVAILABILITY TITLE
          Center(
            child: Text("Availability", style: t.textTheme.titleLarge),
          ),

          const SizedBox(height: 10),

          /// SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildAvailability(room),

                  const SizedBox(height: 24),

                  /// UTILITIES TITLE
                  Text("Utilities", style: t.textTheme.titleLarge),

                  const SizedBox(height: 12),

                  _buildUtilities(room),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// BOOK BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentYellow,
                foregroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side:
                      const BorderSide(color: AppColors.black, width: 1.4),
                ),
                textStyle: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text("Book Room"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailability(RoomDetail room) {
    final t = Theme.of(context);

    final weekday = Weekday.values[selectedDate.weekday - 1];
    final gaps = room.gapsFor(weekday);

    if (gaps.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text("No available slots", style: t.textTheme.bodyMedium),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gaps.length,
      itemBuilder: (context, index) {
        final gap = gaps[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text(
                "${gap.start} - ${gap.end}",
                style: t.textTheme.bodyLarge,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUtilities(RoomDetail room) {
    final t = Theme.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: room.utilities.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3.5,
      ),
      itemBuilder: (context, index) {
        final utility = room.utilities[index];

        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.softYellow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            utility,
            style: t.textTheme.bodyMedium,
          ),
        );
      },
    );
  }
}