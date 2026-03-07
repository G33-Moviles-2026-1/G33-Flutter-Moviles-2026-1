import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart'; // o donde tengas tu MaterialApp

void main() {
  runApp(
    const ProviderScope(
      child: AndespaceApp(),
    ),
  );
}