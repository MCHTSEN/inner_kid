import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_kid/core/theme/theme.dart';
import 'package:inner_kid/features/first_analysis/first_analysis_page.dart';
import 'package:inner_kid/features/landing/landing_page.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inner Kid',
      theme: AppTheme.lightTheme,
      home: const LandingPage(),
    );
  }
}
