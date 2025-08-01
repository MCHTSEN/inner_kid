import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_kid/core/helper/keyboard_unfocus.dart';
import 'package:inner_kid/core/navigation/main_navigation.dart';
import 'package:inner_kid/core/theme/my_theme.dart';

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
        theme: MyTheme.lightTheme,
        home: const LandingPage(),
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
