import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../data/services/revenuecat_service.dart';

final isProProvider = StateNotifierProvider<IsProNotifier, bool>((ref) {
  return IsProNotifier();
});

class IsProNotifier extends StateNotifier<bool> {
  IsProNotifier() : super(false) {
    _checkProStatus();
    _listenToCustomerInfo();
  }

  Future<void> _checkProStatus() async {
    state = await RevenueCatService.isPro;
  }

  void _listenToCustomerInfo() {
    try {
      RevenueCatService.customerInfoStream.listen((customerInfo) {
        state = customerInfo.entitlements.active.isNotEmpty;
      });
    } catch (_) {}
  }

  Future<bool> purchasePackage(Package package) async {
    final info = await RevenueCatService.purchasePackage(package);
    if (info != null) {
      state = info.entitlements.active.isNotEmpty;
      return state;
    }
    return false;
  }

  Future<bool> restorePurchases() async {
    final info = await RevenueCatService.restorePurchases();
    if (info != null) {
      state = info.entitlements.active.isNotEmpty;
    }
    return state;
  }
}

final offeringsProvider = FutureProvider<Offerings?>((ref) {
  return RevenueCatService.getOfferings();
});
