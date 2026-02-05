class Event {
  final String id;
  final String userId;
  final String title;
  final String type;
  final String? description;
  final DateTime date;

  Event({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    this.description,
    required this.date,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json["_id"] as String? ?? "",
      userId: json["userId"] as String? ?? "",
      title: json["title"] as String? ?? "",
      type: json["type"] as String? ?? "appointment",
      description: json["description"] as String?,
      date:
          json["date"] != null ? DateTime.parse(json["date"]) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "_id": id,
      "userId": userId,
      "title": title,
      "type": type,
      "date": date.toIso8601String(),
    };

    if (description != null) {
      data["description"] = description;
    }

    return data;
  }
}
