import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/confession_store.dart';

class ConfessionScreen extends StatefulWidget {
  final Locale contentLocale;
  const ConfessionScreen({super.key, required this.contentLocale});

  @override
  State<ConfessionScreen> createState() => _ConfessionScreenState();
}

class _ConfessionScreenState extends State<ConfessionScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final txt = await ConfessionStore.load();
    if (!mounted) return;
    _ctrl.text = txt;
    setState(() => _loading = false);
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => ConfessionStore.save(v));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppLocalizations>(
      future: AppLocalizations.delegate.load(widget.contentLocale),
      builder: (context, snap) {
        final t = snap.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(t?.confessionPlanner ?? 'Confession Planner'),
            actions: [
              IconButton(
                tooltip: t?.clear ?? 'Clear',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(t?.clear ?? 'Clear'),
                      content: Text(t?.areYouSure ?? 'Are you sure? This cannot be undone.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t?.cancel ?? 'Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t?.clear ?? 'Clear')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await ConfessionStore.clear();
                    if (!mounted) return;
                    _ctrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t?.cleared ?? 'Cleared')));
                  }
                },
              ),
            ],
          ),
          body: (!snap.hasData || _loading)
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      t!.confessionHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onChanged: _onChanged,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: t.writeHere,
                      border: const OutlineInputBorder(),
                    ),
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
