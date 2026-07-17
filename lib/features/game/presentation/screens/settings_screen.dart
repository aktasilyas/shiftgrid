import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/settings/settings_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final adsRemoved = ref.watch(entitlementRepositoryProvider).adsRemoved;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: ListView(
          children: [
            SwitchListTile(
              title: Text(l10n.soundLabel),
              value: settings.soundEnabled,
              onChanged: (_) => notifier.toggleSound(),
              secondary: const Icon(Icons.volume_up),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.languageLabel),
              trailing: DropdownButton<String?>(
                value: settings.languageCode,
                onChanged: notifier.setLanguage,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.systemLanguage),
                  ),
                  const DropdownMenuItem<String?>(
                    value: 'tr',
                    child: Text('Türkçe'),
                  ),
                  const DropdownMenuItem<String?>(
                    value: 'en',
                    child: Text('English'),
                  ),
                ],
              ),
            ),
            const Divider(),
            if (adsRemoved)
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(l10n.adsRemovedActive),
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.block),
                title: Text(l10n.removeAds),
                onTap: () => ref.read(purchaseServiceProvider).buyRemoveAds(),
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: Text(l10n.restorePurchases),
                onTap: () =>
                    ref.read(purchaseServiceProvider).restorePurchases(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
