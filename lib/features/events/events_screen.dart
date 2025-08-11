import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as add2cal;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../l10n/app_localizations.dart';
import '../../data/models/event.dart';
import '../../data/repositories/events_repo.dart';

class EventsScreen extends StatefulWidget {
  final Locale contentLocale;
  const EventsScreen({super.key, required this.contentLocale});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late Future<List<EventModel>> _future;
  String _status = '…';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<EventModel>> _load() async {
    setState(() => _status = 'Loading from Firestore…');
    try {
      final list = await FirestoreEventsRepo().listUpcoming();
      setState(() => _status = 'Loaded ${list.length} from Firestore');
      if (list.isNotEmpty) return list;
      setState(() => _status = 'No upcoming events (Firestore empty)');
      return const <EventModel>[];
    } catch (e) {
      // ignore: avoid_print
      print('Firestore events error: $e');
      setState(() => _status = 'Firestore error → showing sample');
      return LocalEventsRepo().listUpcoming();
    }
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _openQuickAdd() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const _QuickAddEventSheet(),
      ),
    );
    if (saved == true) {
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Event saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppLocalizations>(
      future: AppLocalizations.delegate.load(widget.contentLocale),
      builder: (context, snap) {
        final t = snap.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(t?.events ?? 'Events'),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
                onPressed: _refresh,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openQuickAdd,
            child: const Icon(Icons.add),
          ),
          body: !snap.hasData
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<EventModel>>(
            future: _future,
            builder: (context, ev) {
              if (ev.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final events = ev.data ?? const <EventModel>[];

              if (events.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t!.events,
                            style:
                            Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Text(
                          _status,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        const _HelpCard(),
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: _refresh,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final e = events[i];
                    return Card(
                      child: ListTile(
                        title: Text(e.title),
                        subtitle: Text(
                          '${formatEventWindow(e.start, e.end)}\n${e.location}',
                        ),
                        isThreeLine: true,
                        trailing: FilledButton(
                          onPressed: () async {
                            try {
                              final evt = add2cal.Event(
                                title: e.title,
                                description: e.description,
                                location: e.location,
                                startDate: e.start,
                                endDate: e.end,
                              );
                              await add2cal.Add2Calendar.addEvent2Cal(evt);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                  Text(t!.eventOpenedCalendar),
                                ),
                              );
                            } catch (_) {
                              final msg = kIsWeb
                                  ? t!.eventWebNotSupported
                                  : t!.eventAddFailed;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(msg)),
                              );
                            }
                          },
                          child: Text(t!.addToCalendar),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: const [
            Text('If nothing shows, check Firestore:'),
            SizedBox(height: 8),
            Text('• Collection: events', textAlign: TextAlign.center),
            Text('• Fields: title, description, location (string)', textAlign: TextAlign.center),
            Text('• Fields: start, end (timestamp)', textAlign: TextAlign.center),
            Text('• start must be today or future', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Bottom-sheet quick add form
class _QuickAddEventSheet extends StatefulWidget {
  const _QuickAddEventSheet();

  @override
  State<_QuickAddEventSheet> createState() => _QuickAddEventSheetState();
}

class _QuickAddEventSheetState extends State<_QuickAddEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();
  DateTime? _start = DateTime.now().add(const Duration(hours: 1));
  DateTime? _end = DateTime.now().add(const Duration(hours: 2));
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final base = initial ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (date == null) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_start == null || _end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick start/end')),
      );
      return;
    }
    if (!_end!.isAfter(_start!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End must be after start')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('events').add({
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'location': _location.text.trim(),
        'start': Timestamp.fromDate(_start!),
        'end': Timestamp.fromDate(_end!),
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + insets.bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('New event', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start'),
                subtitle: Text(_start == null ? 'Select…' : _start!.toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final dt = await _pickDateTime(_start);
                    if (dt != null) setState(() => _start = dt);
                  },
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End'),
                subtitle: Text(_end == null ? 'Select…' : _end!.toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final dt = await _pickDateTime(_end);
                    if (dt != null) setState(() => _end = dt);
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                      height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
