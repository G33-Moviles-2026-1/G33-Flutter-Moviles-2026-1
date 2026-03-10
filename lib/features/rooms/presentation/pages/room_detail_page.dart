import 'package:andespace/features/rooms/presentation/widgets/room_detail_body.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/room_search.dart';

class RoomDetailPage extends StatelessWidget {
  // Recibimos el objeto room por el constructor
  final RoomSearchItem room;

  const RoomDetailPage({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Details'),
        centerTitle: true,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: RoomDetailBody(room: room),
    );
  }
}