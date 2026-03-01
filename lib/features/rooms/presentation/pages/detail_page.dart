import 'package:andespace/features/rooms/domain/entities/room_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/room_detail_cubit.dart';
import '../cubit/room_detail_state.dart';
import '../../data/repositories/mock_room_repository.dart';

class RoomDetailPage extends StatelessWidget {
  final String roomId;

  const RoomDetailPage({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RoomDetailCubit(MockRoomRepository())..fetchRoomDetail(roomId),
      child: const _RoomDetailView(),
    );
  }
}

class _RoomDetailView extends StatelessWidget {
  const _RoomDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RoomDetailCubit, RoomDetailState>(
        builder: (context, state) {
          if (state is RoomDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RoomDetailLoaded) {
            final room = state.roomDetail;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.id,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    room.buildingName,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Text(
                        "Reliability:",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Text("${room.reliability.toStringAsFixed(0)}%"),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text("Capacity: ${room.capacity}"),

                  const SizedBox(height: 16),
 
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: room.utilities
                        .map((u) => Chip(label: Text(u)))
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Available Gaps",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.builder(
                      itemCount: room.gapsFor(Weekday.monday).length,
                      itemBuilder: (_, index) {
                        final gap = room.gapsFor(Weekday.monday)[index];

                        return Card(
                          child: ListTile(
                            title: Text(
                              "${gap.start} - ${gap.end}" 
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is RoomDetailError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
