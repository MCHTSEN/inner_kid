import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_kid/core/helper/keyboard_unfocus.dart';
import 'package:inner_kid/core/navigation/main_navigation.dart';
import 'package:inner_kid/core/theme/my_theme.dart';
import 'package:inner_kid/features/subscription/presentation/hard_paywall.dart';
import 'package:logger/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'features/auth/views/login_page.dart';
import 'features/landing/landing_page.dart';
import 'features/splash/splash_page.dart';
import 'features/subscription/revenuecat_sevices.dart';
import 'firebase_options.dart';

Logger logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  await Purchases.setLogLevel(LogLevel.debug);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure RevenueCat
  await RevenueCatServices.configureRevenueCat();

  runApp(
    const ProviderScope(
      child: InnerKidApp(),
    ),
  );

  // runApp(
  
  //   DevicePreview(
  //     enabled: true, // Debug modunda aktif olsun
  //     builder: (context) => const ProviderScope(
  //       child: InnerKidApp(),
  //     ),
  //   ),
  // );
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
        home: const HardPaywall(),
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

// class PaywallScreen extends ConsumerStatefulWidget {
//   const PaywallScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _PaywallScreenState();
// }

// class _PaywallScreenState extends ConsumerState<PaywallScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final offeringAsync = ref.watch(currentOfferingProvider);

//     return Scaffold(
//       body: Center(
//         child: offeringAsync.
//       )
//     );
//   }
// }
