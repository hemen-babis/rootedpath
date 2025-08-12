import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';

import 'services/prefs.dart';
import 'services/cache.dart';
import 'services/notifications_service.dart';
import 'services/firebase_boot.dart';

import 'app/root_scaffold.dart';
import 'features/onboarding/language_screen.dart';
import 'features/onboarding/age_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPrefs.init();
  await CacheService.init();
  try {
    await FirebaseBoot.init();
  } catch (_) {}
  try {
    await NotificationsService.init();
  } catch (_) {}
  runApp(const RootedPathApp());
}

class RootedPathApp extends StatefulWidget {
  const RootedPathApp({super.key});
  @override
  State<RootedPathApp> createState() => _RootedPathAppState();
}

class _RootedPathAppState extends State<RootedPathApp> {
  late Locale _uiLocale;       // en | am (Material/Cupertino chrome)
  late Locale _contentLocale;  // en | am | ti | om (our content)
  bool _onboarded = false;

  @override
  void initState() {
    super.initState();
    final content = (AppPrefs.contentLangCode.isNotEmpty)
        ? AppPrefs.contentLangCode
        : 'en';
    _contentLocale = Locale(content);

    final ui = AppPrefs.uiLangCode;
    _uiLocale = (ui == 'am' || ui == 'en') ? Locale(ui) : const Locale('en');

    _onboarded = AppPrefs.isOnboarded;
  }

  Future<void> _applyLanguageUnified(String code) async {
    // Always set content language
    await AppPrefs.setContentLangCode(code);

    // UI chrome must stay en/am to avoid missing delegates
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
        _contentLocale = Locale(code); // 'ti' or 'om'
      });
    }
  }

  Future<void> _finishOnboarding(String age) async {
    await AppPrefs.setAgeGroup(age);
    await AppPrefs.setOnboarded(true);
    setState(() => _onboarded = true);
  }

  /// Two-step wizard: language -> age
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
          contentLocale: Locale(lang),
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

      // UI chrome (Material/Cupertino) locale
      locale: _uiLocale,
      supportedLocales: const [Locale('en'), Locale('am')],
      localizationsDelegates: const [
        AppLocalizations.delegate, // your app content
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)?.appTitle ?? 'rootedpath',

      // Theming based on content locale (so Ethiopic fonts apply)
      theme: AppTheme.light(_contentLocale),
      darkTheme: AppTheme.dark(_contentLocale),

      // Home
      home: _onboarded
          ? RootScaffold(
        contentLocale: _contentLocale,
        onOpenWizard: _startWizard,
      )
          : _Welcome(onStart: _startWizard),
    );
  }
}

/// Welcome screen: logo + verse + "Get started"
class _Welcome extends StatelessWidget {
  final Future<void> Function(BuildContext) onStart;
  const _Welcome({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
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
                  const FlutterLogo(size: 96),
                  const SizedBox(height: 24),
                  Text(
                    t?.appTitle ?? 'rootedpath',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '“Thy word is a lamp unto my feet, and a light unto my path.”\n— Psalm 119:105',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => onStart(context),
                    child: Text(t?.next ?? 'Next'),
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
