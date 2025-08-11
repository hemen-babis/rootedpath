class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime start;
  final DateTime end;
  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'location': location,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
  };

  static EventModel fromMap(Map<String, dynamic> m) => EventModel(
    id: m['id'],
    title: m['title'],
    description: m['description'],
    location: m['location'],
    start: DateTime.parse(m['start']),
    end: DateTime.parse(m['end']),
  );
}
