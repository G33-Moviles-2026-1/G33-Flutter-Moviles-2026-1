import 'package:andespace/features/rooms/presentation/pages/detail_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RoomDetailPage(
        roomId: "ML 517",
      ),
    );
  }
}