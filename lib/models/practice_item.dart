enum PracticePriority { high, medium, low }

class PracticeItem {
  final String id;
  String text;
  String? songId; // null = song-loses Item ("Allgemein")
  PracticePriority priority;
  bool done;
  final DateTime createdAt;

  PracticeItem({
    required this.id,
    required this.text,
    this.songId,
    this.priority = PracticePriority.medium,
    this.done = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'songId': songId,
    'priority': priority.name,
    'done': done,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PracticeItem.fromJson(Map<String, dynamic> json) {
    return PracticeItem(
      id: json['id'],
      text: json['text'] ?? '',
      songId: json['songId'],
      priority: PracticePriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => PracticePriority.medium,
      ),
      done: json['done'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
