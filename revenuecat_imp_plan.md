RevenueCat + Riverpod Flutter Entegrasyon Planı (Dinamik Paywall)
Proje Yapısı

lib/
revenuecat/
├── providers/
│   ├── revenue_cat_provider.dart
│   └── subscription_provider.dart
├── services/
│   └── revenue_cat_service.dart
├── models/
│   └── subscription_models.dart
└── widgets/
    └── premium_button.dart


Adım 2: Model Sınıfları Oluşturma
Hedef: Subscription durumlarını manage edecek model sınıfları
Dosya: lib/models/subscription_models.dart
dartimport 'package:purchases_flutter/purchases_flutter.dart';

enum SubscriptionStatus {
  notSubscribed,
  subscribed,
  expired,
  loading,
  error
}

class SubscriptionState {
  final SubscriptionStatus status;
  final CustomerInfo? customerInfo;
  final Offerings? offerings;
  final String? errorMessage;
  final bool isLoading;

  const SubscriptionState({
    this.status = SubscriptionStatus.loading,
    this.customerInfo,
    this.offerings,
    this.errorMessage,
    this.isLoading = false,
  });

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    CustomerInfo? customerInfo,
    Offerings? offerings,
    String? errorMessage,
    bool? isLoading,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      customerInfo: customerInfo ?? this.customerInfo,
      offerings: offerings ?? this.offerings,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isPremium => 
    customerInfo?.entitlements.active.isNotEmpty ?? false;
  
  bool get hasActiveSubscription =>
    status == SubscriptionStatus.subscribed && isPremium;
}
Yapılacaklar:

 Model dosyasını oluştur
 Enum'ları tanımla
 SubscriptionState sınıfını implement et
 Helper method'ları ekle

Adım 3: RevenueCat Service Katmanı
Hedef: RevenueCat işlemlerini handle edecek service sınıfı
Dosya: lib/services/revenue_cat_service.dart
dartimport 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class RevenueCatService {
  static const String _apiKeyIOS = 'YOUR_IOS_API_KEY';
  static const String _apiKeyAndroid = 'YOUR_ANDROID_API_KEY';
  static const String _entitlementID = 'premium'; // RevenueCat dashboard'tan
  
  static String get _apiKey => Platform.isIOS ? _apiKeyIOS : _apiKeyAndroid;
  
  static Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);
    
    PurchasesConfiguration configuration = PurchasesConfiguration(_apiKey);
    await Purchases.configure(configuration);
    
    // Listener'ları setup et
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdate);
  }
  
  static void _onCustomerInfoUpdate(CustomerInfo customerInfo) {
    // Provider'a notify et (Adım 4'te implement edilecek)
    print('Customer info updated: ${customerInfo.activeSubscriptions}');
  }
  
  static Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo();
  }
  
  static Future<Offerings> getOfferings() async {
    return await Purchases.getOfferings();
  }
  
  // Dinamik paywall gösterme - RevenueCat UI ile
  static Future<bool> presentPaywall({String? offeringIdentifier}) async {
    try {
      final result = await RevenueCatUI.presentPaywall(
        offeringIdentifier: offeringIdentifier,
      );
      return result == PaywallResult.purchased;
    } catch (e) {
      print('Paywall presentation error: $e');
      return false;
    }
  }
  
  // Paywall gerekli mi kontrol et ve göster
  static Future<bool> presentPaywallIfNeeded({
    required String requiredEntitlementIdentifier,
    String? offeringIdentifier,
  }) async {
    try {
      final result = await RevenueCatUI.presentPaywallIfNeeded(
        requiredEntitlementIdentifier: requiredEntitlementIdentifier,
        offeringIdentifier: offeringIdentifier,
      );
      return result == PaywallResult.purchased;
    } catch (e) {
      print('Paywall if needed error: $e');
      return false;
    }
  }
  
  static Future<CustomerInfo> restorePurchases() async {
    return await Purchases.restorePurchases();
  }
  
  static Future<void> identify(String userId) async {
    await Purchases.logIn(userId);
  }
  
  static Future<void> logout() async {
    await Purchases.logOut();
  }
  
  static bool isPremiumUser(CustomerInfo? customerInfo) {
    return customerInfo?.entitlements.active.containsKey(_entitlementID) ?? false;
  }
  
  // Check if user has specific entitlement
  static bool hasEntitlement(CustomerInfo? customerInfo, String entitlementId) {
    return customerInfo?.entitlements.active.containsKey(entitlementId) ?? false;
  }
}
Yapılacaklar:

 Service dosyasını oluştur
 API key'leri ekle (RevenueCat dashboard'tan)
 Initialize method'unu implement et
 Dinamik paywall methods ekle
 Error handling ekle

Adım 4: Riverpod Provider'lar
Hedef: State management için Riverpod provider'ları oluşturma
Dosya: lib/providers/revenue_cat_provider.dart
dartimport 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../models/subscription_models.dart';
import '../services/revenue_cat_service.dart';

// Customer Info Provider
final customerInfoProvider = FutureProvider<CustomerInfo>((ref) async {
  return await RevenueCatService.getCustomerInfo();
});

// Offerings Provider
final offeringsProvider = FutureProvider<Offerings>((ref) async {
  return await RevenueCatService.getOfferings();
});

// Subscription State Provider
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier();
});

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(const SubscriptionState()) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final customerInfo = await RevenueCatService.getCustomerInfo();
      final offerings = await RevenueCatService.getOfferings();
      
      final isPremium = RevenueCatService.isPremiumUser(customerInfo);
      final status = isPremium 
        ? SubscriptionStatus.subscribed 
        : SubscriptionStatus.notSubscribed;
      
      state = SubscriptionState(
        status: status,
        customerInfo: customerInfo,
        offerings: offerings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }
  
  // Dinamik paywall göster
  Future<bool> showPaywall({String? offeringIdentifier}) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final purchased = await RevenueCatService.presentPaywall(
        offeringIdentifier: offeringIdentifier,
      );
      
      if (purchased) {
        await refreshCustomerInfo();
      } else {
        state = state.copyWith(isLoading: false);
      }
      
      return purchased;
    } catch (e) {
      state = state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }
  
  // Gerekli ise paywall göster
  Future<bool> showPaywallIfNeeded({
    required String entitlementId, 
    String? offeringIdentifier
  }) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final purchased = await RevenueCatService.presentPaywallIfNeeded(
        requiredEntitlementIdentifier: entitlementId,
        offeringIdentifier: offeringIdentifier,
      );
      
      if (purchased) {
        await refreshCustomerInfo();
      } else {
        state = state.copyWith(isLoading: false);
      }
      
      return purchased;
    } catch (e) {
      state = state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }
  
  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final customerInfo = await RevenueCatService.restorePurchases();
      final isPremium = RevenueCatService.isPremiumUser(customerInfo);
      
      state = state.copyWith(
        status: isPremium ? SubscriptionStatus.subscribed : SubscriptionStatus.notSubscribed,
        customerInfo: customerInfo,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }
  
  Future<void> refreshCustomerInfo() async {
    await _initialize();
  }
}

// Premium Status Provider (computed)
final isPremiumProvider = Provider<bool>((ref) {
  final subscriptionState = ref.watch(subscriptionProvider);
  return subscriptionState.isPremium;
});

// Specific Entitlement Provider
final entitlementProvider = Provider.family<bool, String>((ref, entitlementId) {
  final subscriptionState = ref.watch(subscriptionProvider);
  return RevenueCatService.hasEntitlement(subscriptionState.customerInfo, entitlementId);
});
Yapılacaklar:

 Provider dosyasını oluştur
 FutureProvider'ları implement et
 StateNotifierProvider oluştur
 SubscriptionNotifier sınıfını yazı
 Dinamik paywall methods ekle
 Error handling ekle

Adım 5: Main App Setup
Hedef: Uygulamayı Riverpod ve RevenueCat ile başlatma
Dosya: lib/main.dart
dartimport 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/revenue_cat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // RevenueCat'i initialize et
  await RevenueCatService.initialize();
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
Dosya: lib/app.dart
dartimport 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'RevenueCat Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
Yapılacaklar:

 main.dart'ı güncelle
 ProviderScope ekle
 RevenueCat initialize et
 App.dart oluştur

Adım 6: Home Screen Implementation
Hedef: Ana ekranı Riverpod ile entegre etme
Dosya: lib/screens/home_screen.dart
dartimport 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/revenue_cat_provider.dart';
import '../widgets/premium_button.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final isPremium = ref.watch(isPremiumProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('RevenueCat Demo'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(subscriptionProvider.notifier).refreshCustomerInfo();
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Premium Status Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      isPremium ? Icons.verified : Icons.lock,
                      size: 48,
                      color: isPremium ? Colors.green : Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      isPremium ? 'Premium Aktif' : 'Premium Değil',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (subscriptionState.isLoading)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: CircularProgressIndicator(),
                      ),
                    if (subscriptionState.errorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Hata: ${subscriptionState.errorMessage}',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Premium Features List
            Expanded(
              child: ListView(
                children: [
                  _buildFeatureCard(
                    context,
                    ref,
                    'Reklamsız Deneyim',
                    'Tüm reklamları kaldır',
                    'premium',
                    Icons.block,
                  ),
                  _buildFeatureCard(
                    context,
                    ref,
                    'Gelişmiş Özellikler',
                    'Tüm premium özelliklere erişim',
                    'premium',
                    Icons.star,
                  ),
                  _buildFeatureCard(
                    context,
                    ref,
                    'Öncelikli Destek',
                    '7/24 öncelikli müşteri desteği',
                    'premium',
                    Icons.support_agent,
                  ),
                ],
              ),
            ),
            
            // Premium Button
            if (!isPremium) PremiumButton(),
            
            // Restore Button
            TextButton(
              onPressed: subscriptionState.isLoading ? null : () async {
                await ref.read(subscriptionProvider.notifier).restorePurchases();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Satın almalar kontrol edildi')),
                );
              },
              child: Text('Satın Almaları Geri Yükle'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureCard(
    BuildContext context, 
    WidgetRef ref,
    String title, 
    String description, 
    String entitlementId,
    IconData icon,
  ) {
    final hasEntitlement = ref.watch(entitlementProvider(entitlementId));
    
    return Card(
      child: ListTile(
        leading: Icon(
          hasEntitlement ? Icons.check_circle : icon,
          color: hasEntitlement ? Colors.green : Colors.grey,
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: hasEntitlement ? null : Icon(Icons.arrow_forward_ios),
        onTap: hasEntitlement ? null : () async {
          // Premium olmayan kullanıcılar için dinamik paywall göster
          final purchased = await ref.read(subscriptionProvider.notifier)
            .showPaywallIfNeeded(entitlementId: entitlementId);
          
          if (purchased) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Premium özellikler aktif edildi!')),
            );
          }
        },
      ),
    );
  }
}
Yapılacaklar:

 HomeScreen dosyasını oluştur
 ConsumerWidget extend et
 Riverpod provider'ları kullan
 Premium status göster
 Feature list oluştur
 Dinamik paywall entegrasyonu

Adım 7: Premium Button Widget
Hedef: Yeniden kullanılabilir premium button
Dosya: lib/widgets/premium_button.dart
dartimport 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/revenue_cat_provider.dart';

class PremiumButton extends ConsumerWidget {
  final String? text;
  final String? offeringIdentifier;
  final VoidCallback? onPressed;
  
  const PremiumButton({
    Key? key,
    this.text,
    this.offeringIdentifier,
    this.onPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final isPremium = ref.watch(isPremiumProvider);
    
    if (isPremium) {
      return SizedBox.shrink(); // Premium kullanıcılara gösterme
    }
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: subscriptionState.isLoading ? null : (onPressed ?? () async {
          // Dinamik paywall göster
          final purchased = await ref.read(subscriptionProvider.notifier)
            .showPaywall(offeringIdentifier: offeringIdentifier);
          
          if (purchased) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Premium satın alındı!')),
            );
          }
        }),
        child: subscriptionState.isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 20),
                SizedBox(width: 8),
                Text(
                  text ?? 'Premium\'a Geç',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
Yapılacaklar:

 PremiumButton widget'ını oluştur
 ConsumerWidget extend et
 Loading state handle et
 Premium kullanıcılara gösterme
 Dinamik paywall trigger ekle
 Özelleştirilebilir yap

Adım 8: Test ve Debug
Hedef: Entegrasyonu test etme ve hata ayıklama
Test Checklist:

 App başlatma test et
 Provider'ların çalıştığını kontrol et
 Dinamik paywall'ın açıldığını test et
 RevenueCat Dashboard'da paywall template'lerini kontrol et
 Sandbox satın alma test et
 Restore purchases test et
 Premium durumunun güncellediğini kontrol et
 Error handling test et
 Farklı offering'ler ile test et

Debug Adımları:

Flutter Inspector ile widget tree kontrol et
Riverpod DevTools ile state değişimlerini izle
RevenueCat Dashboard'da transaction'ları kontrol et
Console log'larını incele
Paywall template'lerinin doğru göründüğünü kontrol et

Adım 9: RevenueCat Dashboard Paywall Configuration
Hedef: Dashboard'da dinamik paywall'ları configure etme
RevenueCat Dashboard'da Yapılacaklar:

 Paywalls sekmesine git
 Yeni paywall template oluştur
 Template design'ını customize et
 Offering'lere paywall'ları assign et
 A/B test setup'ı (opsiyonel)
 Localization ayarları
 Preview ve test

Paywall Template Elements:

Header image/video
Title ve subtitle
Product cards
Features list
Call-to-action buttons
Terms ve privacy links
Close button behavior

Adım 10: Production Hazırlığı
Hedef: Production'a geçiş için son kontroller
Yapılacaklar:

 API key'leri production key'ler ile değiştir
 Debug log'ları kapat (LogLevel.info)
 Error handling'i iyileştir
 Analytics entegrasyonu (opsiyonel)
 Store'larda test et
 Performance test yap
 Paywall loading time'ları optimize et
 Network timeout handling ekle

Önemli Notlar
Dinamik Paywall Avantajları

Code-free updates: App update olmadan paywall değişikliği
A/B testing: Dashboard'dan test setup'ı
Localization: Otomatik çoklu dil desteği
Templates: Ready-to-use professional designs
Remote config: Pricing, features, design değişiklikleri

RevenueCat Dashboard Ayarları

Entitlement ID'yi (premium) doğru tanımla
Paywall template'lerini offerings ile eşleştir
Products'ları store ID'leri ile bağla
Webhook'ları setup et (backend varsa)

Riverpod Best Practices

Provider'ları global scope'ta tanımla
StateNotifier'da immutable state kullan
AsyncValue için when() method'unu kullan
Ref.read() sadece event handler'larda kullan

Test Stratejisi

Sandbox environment kullan
iOS/Android'de ayrı test hesapları
Farklı paywall template'leri test et
Network offline/online durumlarını test et
App kill/restart senaryolarını test et

Paywall Best Practices

Loading states göster
Error handling implement et
User experience optimize et
Close button behavior'ını ayarla
Restoration flow'unu test et