import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

// Feature screens (make sure these files exist)
import '../features/readings/reading_screen.dart';
import '../features/prayer/prayer_screen.dart';
import '../features/events/events_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/churches/churches_screen.dart';
// If you already created LessonsScreen, uncomment this import and the tile below
// import '../features/lessons/lessons_screen.dart';

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
          _HomeTab(
            contentLocale: widget.contentLocale,
            onOpenWizard: widget.onOpenWizard,
          ),
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
                label: t!.navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.favorite_outline),
                label: t.navPrayer,
              ),
              NavigationDestination(
                icon: const Icon(Icons.event_outlined),
                label: t.navEvents,
              ),
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
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(t!.appTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: t.settings,
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
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Hero / verse card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(.15),
                        child: Icon(
                          Icons.church,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.appTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _welcomeVerse(contentLocale.languageCode),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quick actions grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ActionTile(
                    icon: Icons.menu_book,
                    label: t.dailyReading,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ReadingScreen(contentLocale: contentLocale),
                      ),
                    ),
                  ),
                  _ActionTile(
                    icon: Icons.favorite,
                    label: t.prayerCorner,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            PrayerScreen(contentLocale: contentLocale),
                      ),
                    ),
                  ),
                  // If you have LessonsScreen, uncomment this tile and the import
                  // _ActionTile(
                  //   icon: Icons.school,
                  //   label: 'Lessons',
                  //   onTap: () => Navigator.of(context).push(
                  //     MaterialPageRoute(
                  //       builder: (_) =>
                  //           LessonsScreen(contentLocale: contentLocale),
                  //     ),
                  //   ),
                  // ),
                  _ActionTile(
                    icon: Icons.event,
                    label: t.navEvents,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            EventsScreen(contentLocale: contentLocale),
                      ),
                    ),
                  ),
                  _ActionTile(
                    icon: Icons.church,
                    label: t.nearestChurch,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ChurchesScreen(contentLocale: contentLocale),
                      ),
                    ),
                  ),
                  _ActionTile(
                    icon: Icons.settings,
                    label: t.settings,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            SettingsScreen(openWizard: onOpenWizard),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

String _welcomeVerse(String lang) {
  switch (lang) {
    case 'am':
      return '«ቃልህ ለእግረቴ ማብራት፣ ለመንገዴም ብርሃን ነው።» — መዝ 119፥105';
    case 'ti':
      return '«ቃልካ መግሩም ለእግረይ መብራሂ እዩ፣ ለመንገዲይ ብርሃን እዩ።» — መዝ 119፥105';
    case 'om':
      return '“Jecha kee bubbee miilla koo fi ifa kara koo ti.” — Faarfannaa 119:105';
    default:
      return '“Your word is a lamp to my feet and a light to my path.” — Psalm 119:105';
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = (Theme.of(context).colorScheme.brightness == Brightness.dark)
        ? cs.surface.withOpacity(.4)
        : cs.surface.withOpacity(.8);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: cs.primary),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
