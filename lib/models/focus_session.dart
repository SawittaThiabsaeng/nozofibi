class FocusSession {
  FocusSession({
    required this.title,
    required this.minutes,
    required this.date,
  });

  final String title;
  final int minutes;
  final DateTime date;

  Map<String, dynamic> toJson() => {
        'title': title,
        'minutes': minutes,
        'date': date.toIso8601String(),
      };

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      title: json['title'],
      minutes: json['minutes'],
      date: DateTime.parse(json['date']),
    );
  }
}