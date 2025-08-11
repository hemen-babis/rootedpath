import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../features/readings/reading_screen.dart';
import '../features/prayer/prayer_screen.dart';
import '../features/events/events_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/churches/churches_screen.dart';
import '../features/confession/confession_screen.dart';

class RootScaffold extends StatefulWidget {
  final Locale contentLocale;
  final Future<void> Function(BuildContext) onOpenWizard;
  const RootScaffold({
    super.key,
    required this.contentLocale,
    required this.onOpenWizard,
  });

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppLocalizations>(
      key: ValueKey('nav-${widget.contentLocale.languageCode}'),
      future: AppLocalizations.delegate.load(widget.contentLocale),
      builder: (context, snap) {
        final t = snap.data;

        final pages = <Widget>[
          _HomeTab(contentLocale: widget.contentLocale, onOpenWizard: widget.onOpenWizard),
          PrayerScreen(contentLocale: widget.contentLocale),
          EventsScreen(contentLocale: widget.contentLocale),
        ];

        return Scaffold(
          body: snap.hasData
              ? pages[_index]
              : const Center(child: CircularProgressIndicator()),
          bottomNavigationBar: snap.hasData
              ? NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  label: t!.navHome),
              NavigationDestination(
                  icon: const Icon(Icons.favorite_outline),
                  label: t.navPrayer),
              NavigationDestination(
                  icon: const Icon(Icons.event_outlined),
                  label: t.navEvents),
            ],
          )
              : null,
        );
      },
    );
  }
}

class _HomeTab extends StatelessWidget {
  final Locale contentLocale;
  final Future<void> Function(BuildContext) onOpenWizard;
  const _HomeTab({
    required this.contentLocale,
    required this.onOpenWizard,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppLocalizations>(
      future: AppLocalizations.delegate.load(contentLocale),
      builder: (context, snap) {
        final t = snap.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(t?.appTitle ?? '...'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: t?.chooseLanguage ?? 'Language',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(openWizard: onOpenWizard),
                    ),
                  );
                },
              ),
            ],
          ),
          body: !snap.hasData
              ? const Center(child: CircularProgressIndicator())
              : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReadingScreen(contentLocale: contentLocale),
                        ),
                      ),
                      child: Text(t!.dailyReading),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PrayerScreen(contentLocale: contentLocale),
                        ),
                      ),
                      child: Text(t.prayerCorner),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChurchesScreen(contentLocale: contentLocale),
                        ),
                      ),
                      child: Text(t.nearestChurch),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ConfessionScreen(contentLocale: contentLocale),
                        ),
                      ),
                      child: Text(t.confessionPlanner),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
