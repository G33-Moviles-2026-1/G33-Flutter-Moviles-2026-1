import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      room.id,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Building: ${room.buildingName}"),
                    Text("Capacity: ${room.capacity}"),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.report), onPressed: () {}),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDate(selectedDate),
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),

                  const SizedBox(width: 8),

                  const Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Availability",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 8),

          _buildAvailability(room),

          const SizedBox(height: 20),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Utilities",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            children: room.utilities.map((u) => Chip(label: Text(u))).toList(),
          ),

          const Spacer(),

          ElevatedButton(
            onPressed: () {},
            child: const Text(
              "Book Room",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailability(RoomDetail room) {
    final weekday = Weekday.values[selectedDate.weekday - 1];
    final gaps = room.gapsFor(weekday);

    if (gaps.isEmpty) {
      return const Text("No available slots");
    }

    return Card(
      child: Column(
        children: gaps.map((gap) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Text("${gap.start} - ${gap.end}"),
          );
        }).toList(),
      ),
    );
  }
}

Weekday weekdayFromDate(DateTime date) {
  switch (date.weekday) {
    case DateTime.monday:
      return Weekday.monday;
    case DateTime.tuesday:
      return Weekday.tuesday;
    case DateTime.wednesday:
      return Weekday.wednesday;
    case DateTime.thursday:
      return Weekday.thursday;
    case DateTime.friday:
      return Weekday.friday;
    case DateTime.saturday:
      return Weekday.saturday;
    case DateTime.sunday:
      return Weekday.sunday;
    default:
      return Weekday.monday;
  }
}
