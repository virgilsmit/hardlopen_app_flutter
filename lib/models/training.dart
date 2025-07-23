class Training {
  final int id;
  final DateTime date;
  final String title;
  final String warmup;
  final String core;
  final String cooldown;
  final bool isAttending;

  Training({
    required this.id,
    required this.date,
    required this.title,
    required this.warmup,
    required this.core,
    required this.cooldown,
    required this.isAttending,
  });

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String? ?? '',
      warmup: json['warmup'] as String? ?? '',
      core: json['core'] as String? ?? '',
      cooldown: json['cooldown'] as String? ?? '',
      isAttending: json['attending'] as bool? ?? false,
    );
  }
} 