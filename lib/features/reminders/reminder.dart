class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.scheduledAt,
    this.note,
  });

  final String id;
  final String title;
  final DateTime scheduledAt;
  final String? note;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'scheduledAt': scheduledAt.toIso8601String(),
    'note': note,
  };

  factory Reminder.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final title = json['title'];
    final scheduledAt = json['scheduledAt'];
    final note = json['note'];
    if (id is! String ||
        title is! String ||
        scheduledAt is! String ||
        (note != null && note is! String)) {
      throw const FormatException('Stored reminder has invalid fields.');
    }
    return Reminder(
      id: id,
      title: title,
      scheduledAt: DateTime.parse(scheduledAt),
      note: note is String ? note : null,
    );
  }
}
