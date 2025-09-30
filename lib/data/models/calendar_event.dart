class CalendarEvent {
  final String name;
  final DateTime date;
  final String description;

  CalendarEvent({
    required this.name,
    required this.date,
    required this.description,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      name: json['name'],
      date: DateTime.parse(json['date'] as String),
      description: json['description'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
