class Supplements {
  final String id;
  final String name;
  final String description;
  final String foodSources;
  final String imageUrl;

  Supplements({
    required this.id,
    required this.name,
    required this.description,
    required this.foodSources,
    required this.imageUrl,
  });

  factory Supplements.fromJson(Map<String, dynamic> json) {
    return Supplements(
      id: json["_id"] as String,
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      foodSources: json['foodSources'] ?? "",
      imageUrl: json["imageUrl"] ?? "",
    );
  }
}
