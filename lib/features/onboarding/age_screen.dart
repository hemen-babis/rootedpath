import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class AgeScreen extends StatefulWidget {
  final String initial;           // 'children' | 'youth' | 'adult'
  final Locale contentLocale;     // en | am | ti | om
  const AgeScreen({super.key, required this.initial, required this.contentLocale});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  late String _age;

  @override
  void initState() {
    super.initState();
    _age = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    // Load our app strings for the requested content locale (safe for ti/om).
    return FutureBuilder<AppLocalizations>(
      future: AppLocalizations.delegate.load(widget.contentLocale),
      builder: (context, snap) {
        final t = snap.data;
        return Scaffold(
          appBar: AppBar(title: Text(t?.ageGroup ?? '...')),
          body: !snap.hasData
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              RadioListTile<String>(
                value: 'children',
                groupValue: _age,
                onChanged: (v) => setState(() => _age = v ?? 'children'),
                title: Text(t!.children),
              ),
              RadioListTile<String>(
                value: 'youth',
                groupValue: _age,
                onChanged: (v) => setState(() => _age = v ?? 'youth'),
                title: Text(t.youth),
              ),
              RadioListTile<String>(
                value: 'adult',
                groupValue: _age,
                onChanged: (v) => setState(() => _age = v ?? 'adult'),
                title: Text(t.adult),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop<String>(_age),
                child: Text(t.next),
              ),
            ],
          ),
        );
      },
    );
  }
}
