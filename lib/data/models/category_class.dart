class Category {

  final String categoryName;
  final String categoryId;
  final String? colorHex;

  Category ({
    required this.categoryId,
    required this.categoryName,
    this.colorHex,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'] as String,
      categoryName: json['name'] as String,
      colorHex: json['colorHex'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'colorHex': colorHex,
    };
  }
}