class ShphCategory {
  const ShphCategory({
    required this.id,
    required this.name,
    this.slug,
    this.icon,
    this.image,
    this.description,
  });

  factory ShphCategory.fromJson(Map<String, dynamic> json) => ShphCategory(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String?,
        icon: json['icon'] as String?,
        image: json['image'] as String?,
        description: json['description'] as String?,
      );

  final int id;
  final String name;
  final String? slug;
  final String? icon;
  final String? image;
  final String? description;
}
