import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class LanguageScreen extends StatefulWidget {
  final String initial; // en | am | ti | om
  const LanguageScreen({super.key, required this.initial});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _lang;

  @override
  void initState() {
    super.initState();
    _lang = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.chooseLanguage),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LangTile(code: 'en', label: 'English', group: _lang, onChanged: _select),
          _LangTile(code: 'am', label: 'አማርኛ', group: _lang, onChanged: _select),
          _LangTile(code: 'ti', label: 'ትግርኛ', group: _lang, onChanged: _select),
          _LangTile(code: 'om', label: 'Afaan Oromo', group: _lang, onChanged: _select),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop<String>(_lang),
            child: Text(t.next),
          ),
        ],
      ),
    );
  }

  void _select(String v) => setState(() => _lang = v);
}

class _LangTile extends StatelessWidget {
  final String code;
  final String label;
  final String group;
  final void Function(String) onChanged;
  const _LangTile({
    required this.code,
    required this.label,
    required this.group,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: code,
      groupValue: group,
      onChanged: (v) => onChanged(v ?? code),
      title: Text(label),
    );
  }
}
