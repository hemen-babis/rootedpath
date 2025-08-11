import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class PrayerScreen extends StatelessWidget {
  final Locale contentLocale;
  const PrayerScreen({super.key, required this.contentLocale});

  @override
  Widget build(BuildContext context) {
    final tUi = AppLocalizations.of(context)!; // UI (en/am)

    return Scaffold(
      appBar: AppBar(title: Text(tUi.prayerCorner)),
      body: FutureBuilder<AppLocalizations>(
        future: AppLocalizations.delegate.load(contentLocale),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final t = snap.data!; // content in en/am/ti/om
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.morningPrayerTitle, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text(t.morningPrayerBody),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
