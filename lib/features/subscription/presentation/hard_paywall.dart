import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_kid/features/subscription/revenuecat_sevices.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class HardPaywall extends ConsumerStatefulWidget {
  const HardPaywall({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<HardPaywall> {
  Offering? _offering;

  @override
  void initState() {
    super.initState();
    RevenueCatServices.fetchOfferings().then((offerings) {
      setState(() {
        _offering = offerings?.current;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PaywallView(
            offering: _offering,
            onPurchaseCompleted: (customerInfo, storeTransaction) {}));
  }
}
