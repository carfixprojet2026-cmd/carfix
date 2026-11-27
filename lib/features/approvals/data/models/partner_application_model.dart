import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerApplicationModel {
  final String id;
  final String name;
  final String type; // 'garage' | 'parts_shop'
  final String categoryTag; // e.g. 'GARAGE • Oil & Scanner', 'PARTS SHOP • 7-Day Pickup'
  final String address;
  final String contactPerson;
  final String phone;
  final String specsSummary;
  final String cityBadge;
  final String specsBadge;
  final String? imageUrl;
  final String status; // 'pending' | 'approved' | 'rejected'
  final DateTime createdAt;

  const PartnerApplicationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.categoryTag,
    required this.address,
    required this.contactPerson,
    required this.phone,
    required this.specsSummary,
    required this.cityBadge,
    required this.specsBadge,
    this.imageUrl,
    this.status = 'pending',
    required this.createdAt,
  });

  factory PartnerApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return PartnerApplicationModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'garage',
      categoryTag: data['category_tag'] ?? 'GARAGE • Certified',
      address: data['address'] ?? '',
      contactPerson: data['contact_person'] ?? '',
      phone: data['phone'] ?? '',
      specsSummary: data['specs_summary'] ?? '',
      cityBadge: data['city_badge'] ?? 'Regional',
      specsBadge: data['specs_badge'] ?? 'Verified Partner',
      imageUrl: data['image_url'],
      status: data['status'] ?? 'pending',
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'category_tag': categoryTag,
      'address': address,
      'contact_person': contactPerson,
      'phone': phone,
      'specs_summary': specsSummary,
      'city_badge': cityBadge,
      'specs_badge': specsBadge,
      'image_url': imageUrl,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
