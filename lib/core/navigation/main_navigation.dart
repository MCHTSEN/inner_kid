import 'package:flutter/material.dart';
import 'package:inner_kid/core/widgets/floating_bottom_nav.dart';
import 'package:inner_kid/features/analysis/views/analysis_page.dart';
import 'package:inner_kid/features/animation/views/animation_page.dart';
import 'package:inner_kid/features/drawing_tests/views/drawing_tests_page.dart';
import 'package:inner_kid/features/home_dashboard/views/home_dashboard_page.dart';
import 'package:inner_kid/features/profile/views/profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 2; // Start with home dashboard

  final List<Widget> _pages = [
    const AnimationPage(),
    const ProfilePage(),
    const HomeDashboardPage(),
    const DrawingTestsPage(),
    const HomeDashboardPage(), // Home page instead of recommendations
  ];

  void _handleAnalyzeTap() {
    // Navigate to analysis page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AnalysisPage(),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Special handling for analyze button
      _handleAnalyzeTap();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],
          FloatingBottomNav(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
          ),
        ],
      ),
    );
  }
}
