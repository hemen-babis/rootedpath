import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app/theme.dart';
import 'l10n/app_localizations.dart';
import 'services/prefs.dart';
import 'features/onboarding/language_screen.dart';
import 'features/onboarding/age_screen.dart';
import 'features/prayer/prayer_screen.dart';
import 'features/readings/reading_screen.dart';
import 'features/confession/confession_screen.dart';
import 'services/notifications_service.dart';
import 'services/cache.dart';
import 'app/root_scaffold.dart';
import 'services/firebase_boot.dart';
import 'features/settings/settings_screen.dart';
import 'features/feedback/feedback_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPrefs.init();
  await NotificationsService.init();
  await CacheService.init();
  runApp(const RootedPathApp());
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBoot.init();
}

class RootedPathApp extends StatefulWidget {
  const RootedPathApp({super.key});
  @override
  State<RootedPathApp> createState() => _RootedPathAppState();
}

class _RootedPathAppState extends State<RootedPathApp> {
  late Locale _uiLocale;       // en | am for Material/Cupertino
  late Locale _contentLocale;  // en | am | ti | om for our strings
  bool _onboarded = false;

  @override
  void initState() {
    super.initState();
    _contentLocale = Locale(AppPrefs.contentLangCode);
    final ui = AppPrefs.uiLangCode;
    _uiLocale = (ui == 'am' || ui == 'en') ? Locale(ui) : const Locale('en');
    _onboarded = AppPrefs.isOnboarded;
  }

  Future<void> _applyLanguageUnified(String code) async {
    // Always set content language
    await AppPrefs.setContentLangCode(code);

    // UI chrome must stay en/am to avoid delegate issues
    if (code == 'en' || code == 'am') {
      await AppPrefs.setUiLangCode(code);
      setState(() {
        _uiLocale = Locale(code);
        _contentLocale = Locale(code);
      });
    } else {
      await AppPrefs.setUiLangCode('en');
      setState(() {
        _uiLocale = const Locale('en');
        _contentLocale = Locale(code); // ti / om
      });
    }
  }

  Future<void> _finishOnboarding(String age) async {
    await AppPrefs.setAgeGroup(age);
    await AppPrefs.setOnboarded(true);
    setState(() => _onboarded = true);
  }

  // Launch the wizard (can be used at first run or later from settings)
  Future<void> _startWizard(BuildContext context) async {
    // Step 1: Language
    final lang = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => LanguageScreen(initial: AppPrefs.contentLangCode)),
    );
    if (lang == null) return; // cancelled
    await _applyLanguageUnified(lang);

    // Step 2: Age
    final age = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => AgeScreen(
          initial: AppPrefs.ageGroup,
          contentLocale: Locale(lang),   // 👈 pass the selected language here
        ),
      ),
    );
    if (age == null) return; // cancelled
    await _finishOnboarding(age);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _uiLocale,
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('am')],
      theme: appTheme(),
      home: _onboarded
          ? RootScaffold(
        contentLocale: _contentLocale,
        onOpenWizard: _startWizard,
      )
          : _Welcome(
        onStart: _startWizard,
      ),
    );
  }
}

/// Welcome screen: logo + verse + "Get started"
class _Welcome extends StatelessWidget {
  final Future<void> Function(BuildContext) onStart;
  const _Welcome({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App "logo" placeholder — replace with your asset later
                  const FlutterLogo(size: 96),
                  const SizedBox(height: 24),
                  Text(
                    t.appTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  // KJV public-domain verse (safe)
                  Text(
                    '“Thy word is a lamp unto my feet, and a light unto my path.”\n— Psalm 119:105',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => onStart(context),
                    child: Text(t.next), // "Get started"
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Home: minimal shell; opens wizard from gear
// in lib/main.dart

class _Home extends StatelessWidget {
  final Locale contentLocale;
  final Future<void> Function(BuildContext) onOpenWizard;
  const _Home({required this.contentLocale, required this.onOpenWizard});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppLocalizations>(
      key: ValueKey('home-${contentLocale.languageCode}'),
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
                onPressed: () => onOpenWizard(context),
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
                          builder: (_) => ConfessionScreen(contentLocale: contentLocale),
                        ),
                      ),
                      child: Text(t.confessionPlanner),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 360,
                    child: FilledButton.tonal(
                      onPressed: () async {
                        // Web fallback: show a toast/snack
                        try {
                          await NotificationsService.scheduleDailyReading();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Daily reminder scheduled for 7:00 AM')),
                          );
                        } catch (_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reminders supported on Android/iOS')),
                          );
                        }
                      },
                      child: const Text('Enable daily reminder'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      try {
                        await NotificationsService.scheduleTestInSeconds(5);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Test notification in 5s…')),
                        );
                      } catch (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Test works on Android/iOS')),
                        );
                      }
                    },
                    child: const Text('Send test now'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
