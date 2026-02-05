class Exercise {
  final String id;
  final String title;
  final String derscription;
  final String videoId;
  final String category;
  final String duration;
  final String thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Exercise({
    required this.id,
    required this.title,
    required this.derscription,
    required this.videoId,
    required this.category,
    required this.duration,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json["_id"],
      title: json["title"],
      derscription: json["derscription"] ?? "",
      videoId: json["videoId"],
      category: json["category"],
      duration: json["duration"],
      thumbnailUrl: json["thumbnailUrl"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}
