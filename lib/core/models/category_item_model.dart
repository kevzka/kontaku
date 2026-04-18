class CategoryItemModel {
  final String number;
  final String category;

  const CategoryItemModel({required this.number, required this.category});

  factory CategoryItemModel.fromFirestoreMap(Map<String, dynamic> data) {
    return CategoryItemModel(
      number: data['number'] as String? ?? '',
      category: data['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {'number': number, 'category': category};
  }
}
