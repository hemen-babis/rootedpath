import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/prefs.dart';
import '../../services/notifications_service.dart';
import '../../services/cache.dart';

class SettingsScreen extends StatefulWidget {
  final Future<void> Function(BuildContext) openWizard; // to change language/age
  const SettingsScreen({super.key, required this.openWizard});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _enabled;
  late TimeOfDay _time;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _enabled = AppPrefs.reminderEnabled;
    _time = AppPrefs.reminderTime;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() => _time = picked);
      await AppPrefs.setReminderTime(picked);
      if (_enabled && !kIsWeb) {
        await NotificationsService.scheduleDailyReading(at: picked);
      }
    }
  }

  Future<void> _toggle(bool v) async {
    setState(() => _enabled = v);
    await AppPrefs.setReminderEnabled(v);
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminders are mobile-only')),
      );
      return;
    }
    if (v) {
      await NotificationsService.scheduleDailyReading(at: _time);
    } else {
      await NotificationsService.cancelDaily();
    }
  }

  Future<void> _clearCache() async {
    setState(() => _busy = true);
    await CacheService.clearAll();
    if (mounted) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offline cache cleared')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        children: [
          ListTile(
            title: Text(t.languageAndAge),
            subtitle: Text(t.changeLanguageAgeHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => widget.openWizard(context),
          ),
          const Divider(height: 0),

          SwitchListTile(
            title: Text(t.dailyReminder),
            subtitle: Text('${t.atTime} ${_time.format(context)}'),
            value: _enabled,
            onChanged: _toggle,
          ),
          ListTile(
            title: Text(t.changeReminderTime),
            onTap: _pickTime,
            enabled: _enabled,
          ),
          const Divider(height: 0),

          ListTile(
            title: Text(t.clearOfflineCache),
            trailing: _busy
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.delete_outline),
            onTap: _busy ? null : _clearCache,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
