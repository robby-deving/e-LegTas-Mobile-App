// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:e_legtas/app.dart'; // Import your ELegtasApp

void main() {
  runApp(
    const ProviderScope( // Wrap your app with ProviderScope
      child: ELegtasApp(),
    ),
  );
}