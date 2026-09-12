import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/constants/app_constants.dart';

class RevenueCatService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);

      PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(AppConstants.revenueCatAndroidKey);
      } else if (Platform.isIOS || Platform.isMacOS) {
        configuration = PurchasesConfiguration(AppConstants.revenueCatIosKey);
      } else {
        // Fallback for Windows/Web during dev
        configuration = PurchasesConfiguration(AppConstants.revenueCatAndroidKey);
      }

      await Purchases.configure(configuration);
      _initialized = true;
    } catch (e) {
      debugPrint('RevenueCat initialization notice: $e');
    }
  }

  static Future<bool> get isPro async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active
          .containsKey(AppConstants.proEntitlement);
    } catch (e) {
      debugPrint('RevenueCat isPro check fallback: $e');
      return false;
    }
  }

  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('RevenueCat getOfferings notice: $e');
      return null;
    }
  }

  static Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      return await Purchases.purchasePackage(package);
    } on PurchasesErrorCode catch (e) {
      if (e != PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('RevenueCat purchase error: $e');
      }
      return null;
    } catch (e) {
      debugPrint('RevenueCat purchase exception: $e');
      return null;
    }
  }

  static Future<CustomerInfo?> restorePurchases() async {
    try {
      return await Purchases.restorePurchases();
    } catch (e) {
      debugPrint('RevenueCat restore notice: $e');
      return null;
    }
  }

  static Stream<CustomerInfo> get customerInfoStream =>
      Purchases.customerInfoStream;
}
