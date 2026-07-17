import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'entitlement_repository.dart';

/// Skeleton in-app-purchase flow for the non-consumable "remove ads" product.
///
/// The store product (`remove_ads`) is not yet configured in Play Console, so
/// purchases won't complete end-to-end; the wiring (query → buy → deliver →
/// restore) is in place and grants the entitlement on success. Tracked in
/// docs/BACKLOG.md.
class PurchaseService {
  PurchaseService(this._entitlement, {InAppPurchase? iap})
      : _iap = iap ?? InAppPurchase.instance;

  static const String removeAdsId = 'remove_ads';

  final InAppPurchase _iap;
  final EntitlementRepository _entitlement;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  Future<void> initialize() async {
    _sub = _iap.purchaseStream.listen(
      _onPurchasesUpdated,
      onError: (Object e) => debugPrint('purchaseStream error: $e'),
    );
    await restorePurchases();
  }

  Future<bool> isAvailable() => _iap.isAvailable();

  Future<List<ProductDetails>> queryProducts() async {
    final response = await _iap.queryProductDetails({removeAdsId});
    return response.productDetails;
  }

  Future<void> buyRemoveAds() async {
    final products = await queryProducts();
    if (products.isEmpty) {
      debugPrint('remove_ads product not configured yet');
      return;
    }
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: products.first),
    );
  }

  Future<void> restorePurchases() => _iap.restorePurchases();

  Future<void> _onPurchasesUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      final delivered = purchase.productID == removeAdsId &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored);
      if (delivered) {
        await _entitlement.setAdsRemoved(true);
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  void dispose() => _sub?.cancel();
}
