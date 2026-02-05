class Symptom {
  final String id;
  final String userId;
  final String category;
  final DateTime date;
  final List<SymptomItem>? symptom;

  Symptom({
    required this.id,
    required this.userId,
    required this.category,
    required this.date,
    required this.symptom,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json["_id"] as String? ?? "",
      userId: json["userId"] as String? ?? "",
      category: json["category"] as String? ?? "",
      date: json['date'] != null
          ? DateTime.parse(json["date"] as String)
          : DateTime.now(),
      symptom: (json["symptom"] as List<dynamic>?)
              ?.map(
                  (item) => SymptomItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      'userId': userId,
      'category': category,
      'date': date.toIso8601String(),
      'symptom': symptom?.map((item) => item.toJson()).toList(),
    };
  }
}

class SymptomItem {
  final String name;
  final int severity;
  final String? notes;

  SymptomItem({
    required this.name,
    required this.severity,
    this.notes,
  });

  factory SymptomItem.fromJson(Map<String, dynamic> json) {
    return SymptomItem(
      name: json["name"] as String? ?? "",
      severity: (json["severity"] as num?)?.toInt() ?? 5,
      notes: json["notes"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'severity': severity,
      'notes': notes,
    };
  }
}
