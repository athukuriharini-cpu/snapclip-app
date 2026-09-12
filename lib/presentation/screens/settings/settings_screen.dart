import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/snippets_provider.dart';
import '../../widgets/premium_badge.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPro = ref.watch(isProProvider);
    final snippetCount = ref.watch(snippetsProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Pro Card Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPro
                    ? [AppColors.primaryDark, AppColors.primary]
                    : [const Color(0xFF2C2C4E), const Color(0xFF1E1E38)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'SnapClip Pro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isPro)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPro
                            ? 'All Pro features unlocked!'
                            : '$snippetCount / ${AppConstants.freeSnippetLimit} free snippets used',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isPro)
                  FilledButton(
                    onPressed: () => context.push('/paywall'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Upgrade'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Vault Section
          _buildSectionHeader('VAULT & ORGANIZATION'),
          _buildSettingsTile(
            icon: Icons.folder_outlined,
            title: 'Manage Categories',
            subtitle: 'Add, edit, or delete snippet folders',
            onTap: () => context.push('/categories'),
          ),
          _buildSettingsTile(
            icon: Icons.search_rounded,
            title: 'Search Vault',
            subtitle: 'Find snippets across all tags and categories',
            onTap: () => context.push('/search'),
          ),
          const SizedBox(height: 16),

          // Subscription Section
          _buildSectionHeader('MEMBERSHIP'),
          _buildSettingsTile(
            icon: Icons.card_membership_rounded,
            title: 'SnapClip Pro',
            subtitle: isPro ? 'Manage active plan' : 'Unlock unlimited storage & features',
            trailing: isPro ? null : const PremiumBadge(),
            onTap: () => context.push('/paywall'),
          ),
          _buildSettingsTile(
            icon: Icons.restore_rounded,
            title: 'Restore Purchases',
            subtitle: 'Re-activate existing subscription on this device',
            onTap: () async {
              final success = await ref.read(isProProvider.notifier).restorePurchases();
              if (context.mounted) {
                context.showSnackBar(
                  success ? 'Purchases restored!' : 'No active subscription found.',
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // About & Support
          _buildSectionHeader('ABOUT & SUPPORT'),
          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Contact Support',
            subtitle: AppConstants.supportEmail,
            onTap: () => launchUrl(Uri.parse('mailto:${AppConstants.supportEmail}')),
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => launchUrl(Uri.parse(AppConstants.privacyUrl)),
          ),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => launchUrl(Uri.parse(AppConstants.termsUrl)),
          ),
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'Version',
            trailing: Text(
              AppConstants.appVersion,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
            onTap: null,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant))
            : null,
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, size: 20) : null),
        onTap: onTap,
      ),
    );
  }
}
