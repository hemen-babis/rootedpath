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
      // no docs matched the query
      setState(() => _status = 'No upcoming events (Firestore empty)');
      return const <EventModel>[];
    } catch (e) {
      // ignore: avoid_print
      print('Firestore events error: $e');
      setState(() => _status = 'Firestore error → showing sample');
      return LocalEventsRepo().listUpcoming();
    }
  }

  Future<void> _debugCheck() async {
    final app = FirebaseFirestore.instance.app;
    final pid = app.options.projectId;
    try {
      // TODO: replace with an actual doc ID from your screenshot
      const testId = '5eSSFBLYD5sYTmmueQ0o';
      final snap = await FirebaseFirestore.instance.collection('events').doc(testId).get();
      final ok = snap.exists ? 'exists, title=${snap.data()?['title']}' : 'NOT FOUND';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project: $pid • events/$testId $ok')),
      );
      // also print to console
      // ignore: avoid_print
      print('DEBUG Firestore -> project: $pid • events/$testId $ok');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project: $pid • error: $e')),
      );
      // ignore: avoid_print
      print('DEBUG Firestore error: $e');
    }
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
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
                // Friendly empty state + quick checklist
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t!.events, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Text(
                          _status,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        _HelpCard(),
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
                        subtitle: Text('${formatEventWindow(e.start, e.end)}\n${e.location}'),
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
                                SnackBar(content: Text(t!.eventOpenedCalendar)),
                              );
                            } catch (_) {
                              final msg = kIsWeb ? t!.eventWebNotSupported : t!.eventAddFailed;
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
