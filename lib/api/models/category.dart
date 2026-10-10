class ShphCategory {
  const ShphCategory({
    required this.id,
    required this.name,
    this.slug,
    this.icon,
    this.image,
    this.description,
  });

  final int id;
  final String name;
  final String? slug;
  final String? icon;
  final String? image;
  final String? description;

  factory ShphCategory.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    int idInt = 0;
    if (rawId is int) {
      idInt = rawId;
    } else if (rawId != null) {
      idInt = int.tryParse(rawId.toString()) ?? rawId.toString().hashCode.abs();
    }
    return ShphCategory(
      id: idInt,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      icon: json['icon'] as String?,
      image: json['image'] as String?,
      description: json['description'] as String?,
    );
  }
}
