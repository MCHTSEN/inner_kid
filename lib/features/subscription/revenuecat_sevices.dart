import 'package:inner_kid/main.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatServices {
  
  // Configure RevenueCat
  static Future<void> configureRevenueCat(String apiKey) async {
    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      logger.d('RevenueCat configured');
    } catch (e) {
      logger.e('RevenueCat configuration failed: $e');
    }
  }

  // Fetch Offerings
  static Future<Offerings?> fetchOfferings() async {
    try {
      final Offerings offerings = await Purchases.getOfferings();
      logger.d('Offerings fetched: $offerings');
      return offerings;
    } catch (e) {
      logger.e('Offerings fetch failed: $e');
      return null;
    }
  }

  // PURCHASE A PACKAGE
  static Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final PurchaseResult purchaseResult = await Purchases.purchasePackage(package);
      final CustomerInfo customerInfo = purchaseResult.customerInfo;
      logger.d('Package purchased: $package');
      return customerInfo;
    } catch (e) {
      logger.e('Package purchase failed: $e');
    }
    return null;
  }

  // IS PRO USER?
  static Future<bool> isProUser() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      final isPro = customerInfo.entitlements.active.containsKey('pro');
      logger.d('Is pro user: $isPro');
      return isPro;
    } catch (e) {
      logger.e('Is pro user check failed: $e');
      return false;
    }
  }
}
