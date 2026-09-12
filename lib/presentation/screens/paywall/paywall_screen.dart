import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../providers/subscription_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  final String reason;

  const PaywallScreen({super.key, this.reason = 'Upgrade to SnapClip Pro'});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  int _selectedPlanIndex = 1; // 0 = Monthly, 1 = Annual (default recommendation)
  bool _isLoading = false;

  final List<PaywallBenefit> _benefits = const [
    PaywallBenefit('♾️', 'Unlimited Snippets', 'Store as many snippets as you want without caps'),
    PaywallBenefit('📂', 'Unlimited Categories', 'Structure your workflow with endless folders & tags'),
    PaywallBenefit('🖼️', 'Rich Image Snippets', 'Capture screenshots, photos, and graphical assets'),
    PaywallBenefit('⚡', 'Instant Keyboard Widget', 'Access your vault from any app in real-time'),
    PaywallBenefit('☁️', 'Cloud Backup & Sync', 'Keep your snippets safely synchronized across devices'),
    PaywallBenefit('🔒', 'Vault Biometric Lock', 'Protect private tokens and passwords with Face ID/Fingerprint'),
  ];

  void _onPurchase(Offerings? offerings) async {
    setState(() => _isLoading = true);

    try {
      final offering = offerings?.current;
      Package? packageToBuy;

      if (offering != null) {
        if (_selectedPlanIndex == 1 && offering.annual != null) {
          packageToBuy = offering.annual;
        } else if (_selectedPlanIndex == 0 && offering.monthly != null) {
          packageToBuy = offering.monthly;
        } else if (offering.availablePackages.isNotEmpty) {
          packageToBuy = offering.availablePackages.first;
        }
      }

      if (packageToBuy != null) {
        final success = await ref.read(isProProvider.notifier).purchasePackage(packageToBuy);
        if (success && mounted) {
          context.showSnackBar('Welcome to SnapClip Pro! 🎉');
          context.pop();
        }
      } else {
        // Mock fallback for preview & sandbox testing
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.showSnackBar('Simulated Pro purchase completed! (Sandbox mode)');
          context.pop();
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onRestore() async {
    setState(() => _isLoading = true);
    try {
      final success = await ref.read(isProProvider.notifier).restorePurchases();
      if (mounted) {
        if (success) {
          context.showSnackBar('Purchases successfully restored! 🎉');
          context.pop();
        } else {
          context.showSnackBar('No active subscription found to restore.');
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final offeringsAsync = ref.watch(offeringsProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => context.pop(),
                  ),
                ),

                // Pro Header with Glowing Gold Crown
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.premiumGold.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, size: 48, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Unlock SnapClip Pro',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                Center(
                  child: Text(
                    widget.reason,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),

                // Feature List
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2A2A45) : const Color(0xFFE8E8F5),
                    ),
                  ),
                  child: Column(
                    children: _benefits.map((b) => _buildBenefitRow(b)).toList(),
                  ),
                ),
                const SizedBox(height: 28),

                // Pricing Cards (Monthly vs Annual with discount badge)
                Row(
                  children: [
                    // Monthly Plan
                    Expanded(
                      child: _buildPlanCard(
                        index: 0,
                        title: 'Monthly',
                        price: '\$2.99',
                        period: '/ month',
                        isRecommended: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Annual Plan (Featured)
                    Expanded(
                      child: _buildPlanCard(
                        index: 1,
                        title: 'Annual',
                        price: '\$19.99',
                        period: '/ year',
                        tag: 'SAVE 44%',
                        subtitle: '7-Day Free Trial',
                        isRecommended: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Main CTA Button
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _isLoading
                        ? null
                        : () => _onPurchase(offeringsAsync.valueOrNull),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _selectedPlanIndex == 1
                                ? 'Start 7-Day Free Trial'
                                : 'Subscribe Now',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Sub-caption
                Center(
                  child: Text(
                    _selectedPlanIndex == 1
                        ? 'Then \$19.99/year. Cancel anytime before trial ends.'
                        : '\$2.99 billed monthly. Cancel anytime.',
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                // Footer with Restore Purchases & Legal Links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _onRestore,
                      child: const Text('Restore Purchases', style: TextStyle(fontSize: 12)),
                    ),
                    const Text('•', style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () => launchUrl(Uri.parse(AppConstants.privacyUrl)),
                      child: const Text('Privacy Policy', style: TextStyle(fontSize: 12)),
                    ),
                    const Text('•', style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () => launchUrl(Uri.parse(AppConstants.termsUrl)),
                      child: const Text('Terms of Use', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(PaywallBenefit benefit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(benefit.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  benefit.description,
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    required String period,
    String? tag,
    String? subtitle,
    required bool isRecommended,
  }) {
    final isSelected = _selectedPlanIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : (isDark ? AppColors.darkSurface : AppColors.surface),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : const Color(0xFFE8E8F5),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      period,
                      style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (tag != null)
            Positioned(
              top: -10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PaywallBenefit {
  final String icon;
  final String title;
  final String description;

  const PaywallBenefit(this.icon, this.title, this.description);
}
