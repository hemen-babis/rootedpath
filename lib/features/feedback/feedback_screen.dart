import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

class FeedbackScreen extends StatefulWidget {
  final Locale contentLocale;
  const FeedbackScreen({super.key, required this.contentLocale});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _ctrl = TextEditingController();
  bool _busy = false;

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _busy = true);
    final sp = await SharedPreferences.getInstance();
    final history = sp.getStringList('feedback_history') ?? <String>[];
    history.add('${DateTime.now().toIso8601String()}|$text');
    await sp.setStringList('feedback_history', history);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.submitted)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppLocalizations>(
      future: AppLocalizations.delegate.load(widget.contentLocale),
      builder: (context, snap) {
        final t = snap.data;
        return Scaffold(
          appBar: AppBar(title: Text(t?.feedback ?? 'Feedback')),
          body: !snap.hasData
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _ctrl,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: t!.feedbackHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(t.submit),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
