class GameMode {
  final String name;
  final int enemiesCount;

  GameMode({required this.name, required this.enemiesCount});

  factory GameMode.fromJson(Map<String, dynamic> json) {
    return GameMode(
      name: json['name'] as String,
      enemiesCount: json['enemiesCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'enemiesCount': enemiesCount,
    };
  }
}
