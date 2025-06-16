import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/navigation/main_navigation.dart';

void main() {
  runApp(
    const ProviderScope(
      child: InnerKidApp(),
    ),
  );
}

class InnerKidApp extends StatelessWidget {
  const InnerKidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inner Kid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF667EEA),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: GoogleFonts.nunito().fontFamily,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2D3748),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}
