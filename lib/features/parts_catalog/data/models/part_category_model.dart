import 'package:cloud_firestore/cloud_firestore.dart';

class PartCategoryModel {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int partsCount;
  final String? imageUrl;
  final DateTime createdAt;

  const PartCategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.iconName = 'category',
    this.partsCount = 0,
    this.imageUrl,
    required this.createdAt,
  });

  factory PartCategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return PartCategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconName: data['icon_name'] ?? 'category',
      partsCount: (data['parts_count'] as num?)?.toInt() ?? 0,
      imageUrl: data['image_url'],
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'icon_name': iconName,
      'parts_count': partsCount,
      'image_url': imageUrl,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  PartCategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    int? partsCount,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return PartCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      partsCount: partsCount ?? this.partsCount,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
