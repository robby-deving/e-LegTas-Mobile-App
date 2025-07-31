// app.dart
import 'package:flutter/material.dart';
import 'package:e_legtas/features/home/presentation/views/home_view.dart'; // UPDATED PATH
import 'package:e_legtas/features/hotlines/hotlines_view.dart'; // Assuming these paths are correct
import 'package:e_legtas/features/notifications/notifications_view.dart'; // Assuming these paths are correct
import 'package:e_legtas/widgets/navbar.dart'; // UPDATED PATH (assuming this is where your navbar lives)


class ELegtasApp extends StatefulWidget {
  const ELegtasApp({super.key});

  @override
  State<ELegtasApp> createState() => _ELegtasAppState();
}

class _ELegtasAppState extends State<ELegtasApp> {
  int _currentIndex = 0;

  // It's good practice to make this list of pages constant if the pages themselves are constant,
  // but if they might change or be initialized with state, then keep it non-const.
  // For now, let's assume they are stateless or handle their own state.
  final List<Widget> _pages = const [
    HomeView(),
    HotlinesView(), // Ensure HotlinesView and NotificationsView also follow consistent naming/paths
    NotificationsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'e-legtas',
      debugShowCheckedModeBanner: false,
      // You can define global theme here if not already in main.dart
      theme: ThemeData(
        primarySwatch: Colors.green, // Example primary color
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0C955B), // Custom app bar color
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        // Further customize text themes, button themes, etc.
      ),
      home: Scaffold(
        body: IndexedStack( // Use IndexedStack for performance and state preservation
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}