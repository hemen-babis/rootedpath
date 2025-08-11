import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

abstract class EventsRepo {
  Future<List<EventModel>> listUpcoming();
}

/// Reads from Firestore `/events`
class FirestoreEventsRepo implements EventsRepo {
  @override
  Future<List<EventModel>> listUpcoming() async {
    final nowTs = Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 5)));

    final snap = await FirebaseFirestore.instance
        .collection('events')
        .where('start', isGreaterThanOrEqualTo: nowTs)   // requires 'start' to be a Timestamp
        .orderBy('start')
        .limit(100)
        .get();

    final result = <EventModel>[];
    for (final d in snap.docs) {
      try {
        result.add(EventModel.fromDoc(d));
      } catch (e) {
        // Skip bad docs instead of crashing the UI
        // ignore: avoid_print
        print('Skipping bad event doc ${d.id}: $e');
      }
    }
    return result;
  }
}

/// Local fallback if Firestore fails
class LocalEventsRepo implements EventsRepo {
  @override
  Future<List<EventModel>> listUpcoming() async {
    final now = DateTime.now();
    return [
      EventModel(
        id: 'sample',
        title: 'Sample event',
        description: 'This is a local sample shown when Firestore fails.',
        location: 'Your Church',
        start: now.add(const Duration(hours: 3)),
        end:   now.add(const Duration(hours: 4)),
      ),
    ];
  }
}
