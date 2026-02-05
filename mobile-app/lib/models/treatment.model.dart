class Treatment {
  final String id;
  final String userId;
  final String name;
  final DateTime startDate;
  final bool isStopped;

  Treatment({
    required this.id,
    required this.userId,
    required this.name,
    required this.startDate,
    required this.isStopped,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    // Parse the date and convert to local time
    final parsedDate = DateTime.parse(json['startDate']).toLocal();
    // Create a new DateTime with just the year and month to avoid timezone issues
    final localStartDate = DateTime(parsedDate.year, parsedDate.month);

    return Treatment(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      startDate: localStartDate,
      isStopped: json['isStopped'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'startDate': startDate.toUtc().toIso8601String(),
      'isStopped': isStopped,
    };
  }
}
