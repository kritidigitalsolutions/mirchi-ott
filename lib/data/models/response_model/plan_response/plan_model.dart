class PlanModel {
  final String id;
  final String name;
  final int price;
  final int duration;
  final List<String> features;
  final bool isActive;

  PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.features,
    required this.isActive,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      duration: json['duration'] ?? 0,
      features: List<String>.from(json['features'] ?? []),
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
      'duration': duration,
      'features': features,
      'isActive': isActive,
    };
  }
}
