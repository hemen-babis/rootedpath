import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

abstract class EventsRepo {
  Future<List<EventModel>> listUpcoming();
}

class LocalEventsRepo implements EventsRepo {
  @override
  Future<List<EventModel>> listUpcoming() async {
    final now = DateTime.now();
    return [
      EventModel(
        id: '1',
        title: 'Divine Liturgy',
        description: 'Sunday service',
        location: 'St. Michael Church',
        start: DateTime(now.year, now.month, now.day, 9).add(const Duration(days: 1)),
        end: DateTime(now.year, now.month, now.day, 11).add(const Duration(days: 1)),
      ),
      EventModel(
        id: '2',
        title: 'Vespers',
        description: 'Evening prayer',
        location: 'St. Mary Church',
        start: DateTime(now.year, now.month, now.day, 18).add(const Duration(days: 2)),
        end: DateTime(now.year, now.month, now.day, 19).add(const Duration(days: 2)),
      ),
    ];
  }
}

class FirestoreEventsRepo implements EventsRepo {
  final _col = FirebaseFirestore.instance.collection('events');

  @override
  Future<List<EventModel>> listUpcoming() async {
    final now = DateTime.now();
    // Fetch the next 50 by start time, then filter on the client.
    final qs = await _col.orderBy('start').limit(50).get();

    final all = qs.docs.map((d) {
      final m = d.data();
      return EventModel(
        id: d.id,
        title: (m['title'] ?? '') as String,
        description: (m['description'] ?? '') as String,
        location: (m['location'] ?? '') as String,
        start: (m['start'] as Timestamp).toDate(),
        end:   (m['end']   as Timestamp).toDate(),
      );
    }).toList();

    // Show only events that haven't ended yet.
    return all.where((e) => !e.end.isBefore(now)).toList();
  }
}

String formatEventWindow(DateTime start, DateTime end) {
  final d = DateFormat('EEE, MMM d • h:mm a');
  return '${d.format(start)} → ${d.format(end)}';
}
