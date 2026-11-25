import 'package:cloud_firestore/cloud_firestore.dart';

class SparePartModel {
  final String id;
  final String categoryId;
  final String category;
  final String partName;
  final String partNumber; // Manufacturer SKU
  final String oemCrossRef;
  final String fitment; // Applicable vehicle fitment
  final String position; // e.g. "Front Axle Set", "DOT Compliant 4-Pack"
  final String specTag; // e.g. "Standard Spec", "High Temp Teflon"
  final int partnerShopsCount;
  final String? imageUrl;
  final double? price;
  final int stockQuantity;
  final bool isInStock;
  final DateTime createdAt;

  const SparePartModel({
    required this.id,
    required this.categoryId,
    required this.category,
    required this.partName,
    required this.partNumber,
    this.oemCrossRef = '',
    this.fitment = '',
    this.position = 'General Component',
    this.specTag = 'Standard Spec',
    this.partnerShopsCount = 1,
    this.imageUrl,
    this.price,
    this.stockQuantity = 10,
    this.isInStock = true,
    required this.createdAt,
  });

  factory SparePartModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return SparePartModel(
      id: doc.id,
      categoryId: data['category_id'] ?? '',
      category: data['category'] ?? '',
      partName: data['part_name'] ?? '',
      partNumber: data['part_number'] ?? '',
      oemCrossRef: data['oem_cross_ref'] ?? '',
      fitment: data['fitment'] ?? '',
      position: data['position'] ?? 'General Component',
      specTag: data['spec_tag'] ?? 'Standard Spec',
      partnerShopsCount: (data['partner_shops_count'] as num?)?.toInt() ?? 1,
      imageUrl: data['image_url'],
      price: (data['price'] as num?)?.toDouble(),
      stockQuantity: (data['stock_quantity'] as num?)?.toInt() ?? 10,
      isInStock: data['is_in_stock'] ?? true,
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category_id': categoryId,
      'category': category,
      'part_name': partName,
      'part_number': partNumber,
      'oem_cross_ref': oemCrossRef,
      'fitment': fitment,
      'position': position,
      'spec_tag': specTag,
      'partner_shops_count': partnerShopsCount,
      'image_url': imageUrl,
      'price': price,
      'stock_quantity': stockQuantity,
      'is_in_stock': isInStock,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
