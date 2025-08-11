import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime start;
  final DateTime end;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.start,
    required this.end,
  });

  /// Defensive conversion: accepts Timestamp, DateTime, or String; falls back to now.
  static DateTime _toDate(dynamic v, {DateTime? fallback}) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String) {
      final parsed = DateTime.tryParse(v);
      if (parsed != null) return parsed;
    }
    return fallback ?? DateTime.now();
  }

  factory EventModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};

    final start = _toDate(data['start']);
    // If 'end' is null or invalid, make it +1 hour after start so we never crash
    final end = _toDate(data['end'], fallback: start.add(const Duration(hours: 1)));

    return EventModel(
      id: doc.id,
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      location: (data['location'] ?? '').toString(),
      start: start,
      end: end,
    );
  }
}

/// Small helper you’re using in the UI
String formatEventWindow(DateTime start, DateTime end) {
  // Very simple; you can replace with intl DateFormat later
  final s = '${start.year}-${start.month.toString().padLeft(2,'0')}-${start.day.toString().padLeft(2,'0')} '
      '${start.hour.toString().padLeft(2,'0')}:${start.minute.toString().padLeft(2,'0')}';
  final e = '${end.hour.toString().padLeft(2,'0')}:${end.minute.toString().padLeft(2,'0')}';
  return '$s → $e';
}
