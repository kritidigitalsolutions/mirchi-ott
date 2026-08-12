class CategoryModel {
  final String id;
  final String name;
  final String description;
  final int priority;
  final String slug;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priority,
    required this.slug,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 0,
      slug: json['slug'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'priority': priority,
      'slug': slug,
    };
  }
}
