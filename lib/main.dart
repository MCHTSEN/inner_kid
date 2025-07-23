import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/helper/keyboard_unfocus.dart';
import 'package:inner_kid/core/navigation/main_navigation.dart';
import 'package:inner_kid/widgets/apple_lock_button.dart';

import 'features/auth/views/login_page.dart';
import 'features/landing/landing_page.dart';
import 'features/splash/splash_page.dart';
import 'firebase_options.dart';

// ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
    return KeyboardDismissOnTap(
      child: MaterialApp(
        title: 'Inner Kid',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          primaryColor: const Color.fromARGB(255, 135, 234, 102),
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
        home: const SplashPage(),
        routes: {
          '/splash': (context) => const SplashPage(),
          '/landing': (context) => const LandingPage(),
          '/login': (context) => const LoginPage(),
          '/main': (context) => const MainNavigation(),
        },
      ),
    );
  }
}
