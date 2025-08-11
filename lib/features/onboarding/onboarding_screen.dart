import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/prefs.dart';

class OnboardingScreen extends StatefulWidget {
  final Future<void> Function(String langCode, String age) onSaved;
  const OnboardingScreen({super.key, required this.onSaved});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _lang = AppPrefs.contentLangCode; // en | am | ti | om
  String _age  = AppPrefs.ageGroup;        // children | youth | adult

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.chooseLanguage)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _lang,
              decoration: InputDecoration(labelText: t.chooseLanguage),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'am', child: Text('አማርኛ')),
                DropdownMenuItem(value: 'ti', child: Text('ትግርኛ')),
                DropdownMenuItem(value: 'om', child: Text('Afaan Oromo')),
              ],
              onChanged: (v) => setState(() => _lang = v ?? 'en'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _age,
              decoration: InputDecoration(labelText: t.ageGroup),
              items: [
                DropdownMenuItem(value: 'children', child: Text(t.children)),
                DropdownMenuItem(value: 'youth', child: Text(t.youth)),
                DropdownMenuItem(value: 'adult', child: Text(t.adult)),
              ],
              onChanged: (v) => setState(() => _age = v ?? 'adult'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await AppPrefs.setContentLangCode(_lang);
                  await AppPrefs.setAgeGroup(_age);
                  await widget.onSaved(_lang, _age);
                  if (mounted) Navigator.pop(context);
                },
                child: Text(t.next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
