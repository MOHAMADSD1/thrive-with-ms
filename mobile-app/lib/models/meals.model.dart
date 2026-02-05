class Meals {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final List<String>? ingredients;

  Meals({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.ingredients,
  });

  factory Meals.fromJson(Map<String, dynamic> json) {
    return Meals(
      id: json["_id"] as String,
      name: json["name"] as String,
      description: json["description"] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      ingredients: json['ingredients'] != null
          ? List<String>.from(json["ingredients"] as List)
          : null,
    );
  }
}
