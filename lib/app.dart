import 'package:flutter/material.dart';
import 'core/constants/constants.dart';
import 'features/dashboard/view/dashboard_screen.dart';

/// Root application widget.
/// Configures the MaterialApp with theme and home screen.
class ReclaimApp extends StatelessWidget {
  const ReclaimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reclaim',
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}
