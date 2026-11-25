class OilBrandModel {
  final String id;
  final String name;
  final String manufacturer;
  final String tier;
  final int oilCount;
  final String? logoUrl;
  final DateTime? createdAt;

  const OilBrandModel({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.tier,
    this.oilCount = 0,
    this.logoUrl,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'manufacturer': manufacturer,
      'tier': tier,
      'oil_count': oilCount,
      'logo_url': logoUrl,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory OilBrandModel.fromMap(Map<String, dynamic> map, String docId) {
    return OilBrandModel(
      id: docId,
      name: map['name'] as String? ?? 'Unknown Brand',
      manufacturer: map['manufacturer'] as String? ?? '',
      tier: map['tier'] as String? ?? 'OEM Partner',
      oilCount: (map['oil_count'] as num?)?.toInt() ?? 0,
      logoUrl: map['logo_url'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  OilBrandModel copyWith({
    String? id,
    String? name,
    String? manufacturer,
    String? tier,
    int? oilCount,
    String? logoUrl,
    DateTime? createdAt,
  }) {
    return OilBrandModel(
      id: id ?? this.id,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      tier: tier ?? this.tier,
      oilCount: oilCount ?? this.oilCount,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
