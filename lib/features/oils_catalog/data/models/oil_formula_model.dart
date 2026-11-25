class OilFormulaModel {
  final String id;
  final String brandId;
  final String brandName;
  final String viscosity;
  final String title;
  final String composition;
  final String oemSpecs;
  final String categoryTag;
  final int activeGaragesCount;
  final DateTime? createdAt;

  const OilFormulaModel({
    required this.id,
    required this.brandId,
    required this.brandName,
    required this.viscosity,
    required this.title,
    required this.composition,
    required this.oemSpecs,
    required this.categoryTag,
    this.activeGaragesCount = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand_id': brandId,
      'brand_name': brandName,
      'viscosity': viscosity,
      'title': title,
      'composition': composition,
      'oem_specs': oemSpecs,
      'category_tag': categoryTag,
      'active_garages_count': activeGaragesCount,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory OilFormulaModel.fromMap(Map<String, dynamic> map, String docId) {
    return OilFormulaModel(
      id: docId,
      brandId: map['brand_id'] as String? ?? '',
      brandName: map['brand_name'] as String? ?? '',
      viscosity: map['viscosity'] as String? ?? '5W-30',
      title: map['title'] as String? ?? '',
      composition: map['composition'] as String? ?? 'Full Synthetic',
      oemSpecs: map['oem_specs'] as String? ?? '',
      categoryTag: map['category_tag'] as String? ?? 'Standard',
      activeGaragesCount: (map['active_garages_count'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  OilFormulaModel copyWith({
    String? id,
    String? brandId,
    String? brandName,
    String? viscosity,
    String? title,
    String? composition,
    String? oemSpecs,
    String? categoryTag,
    int? activeGaragesCount,
    DateTime? createdAt,
  }) {
    return OilFormulaModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      viscosity: viscosity ?? this.viscosity,
      title: title ?? this.title,
      composition: composition ?? this.composition,
      oemSpecs: oemSpecs ?? this.oemSpecs,
      categoryTag: categoryTag ?? this.categoryTag,
      activeGaragesCount: activeGaragesCount ?? this.activeGaragesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
