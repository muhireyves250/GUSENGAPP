class Broadcast {
  final int id;
  final String title;
  final String description;
  final String type; // 'audio' or 'video'
  final String category;
  final String? audioUrl;
  final String? youtubeUrl;
  final String coverPhoto;
  final String date;
  final String time;

  Broadcast({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    this.audioUrl,
    this.youtubeUrl,
    required this.coverPhoto,
    required this.date,
    required this.time,
  });

  factory Broadcast.fromJson(Map<String, dynamic> json) {
    return Broadcast(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'audio',
      category: json['category'] ?? 'new',
      audioUrl: json['audioUrl'],
      youtubeUrl: json['youtubeUrl'],
      coverPhoto: json['coverPhoto'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }
}
