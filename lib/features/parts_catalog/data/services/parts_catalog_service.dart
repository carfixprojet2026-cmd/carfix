import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../models/part_category_model.dart';
import '../models/spare_part_model.dart';

class PartsCatalogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _categoriesCol =>
      _firestore.collection(FirebaseConstants.colCategories);

  CollectionReference get _partsCol =>
      _firestore.collection(FirebaseConstants.colSpareParts);

  /// Real-time stream of all categories/systems ordered by creation date
  Stream<List<PartCategoryModel>> getCategoriesStream() {
    return _categoriesCol
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PartCategoryModel.fromFirestore(doc)).toList());
  }

  /// Real-time stream of all spare parts
  Stream<List<SparePartModel>> getAllPartsStream() {
    return _partsCol
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SparePartModel.fromFirestore(doc)).toList());
  }

  /// Real-time stream of parts for a specific category
  Stream<List<SparePartModel>> getPartsForCategoryStream(String categoryId) {
    return _partsCol
        .where('category_id', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
      final list =
          snapshot.docs.map((doc) => SparePartModel.fromFirestore(doc)).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  /// Add a new system / category
  Future<void> addCategory(PartCategoryModel category) async {
    await _categoriesCol.doc(category.id).set(category.toMap());
  }

  /// Delete a category and all parts belonging to it
  Future<void> deleteCategory(String categoryId) async {
    final batch = _firestore.batch();
    batch.delete(_categoriesCol.doc(categoryId));

    final parts =
        await _partsCol.where('category_id', isEqualTo: categoryId).get();
    for (final doc in parts.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Add a specific part SKU
  Future<void> addPart(SparePartModel part) async {
    final docRef = _partsCol.doc();
    await docRef.set(part.toMap());

    // Increment category part count
    await _categoriesCol.doc(part.categoryId).update({
      'parts_count': FieldValue.increment(1),
    });
  }

  /// Delete a specific part SKU
  Future<void> deletePart(String partId, String categoryId) async {
    await _partsCol.doc(partId).delete();

    // Decrement category part count
    await _categoriesCol.doc(categoryId).update({
      'parts_count': FieldValue.increment(-1),
    });
  }

  /// Initial seed data if Firestore categories collection is empty
  Future<void> seedInitialDataIfEmpty() async {
    try {
      final snapshot = await _categoriesCol.limit(1).get();
      if (snapshot.docs.isNotEmpty) return;

      final batch = _firestore.batch();

      // Seed 5 standard vehicle systems from design
      final categories = [
        {
          'id': 'brakes',
          'name': 'Brakes & Braking Systems',
          'description': 'Braking assemblies, discs, calipers, lines and pads',
          'icon_name': 'disc_full',
          'parts_count': 4,
          'image_url':
              'https://images.unsplash.com/photo-1600790142055-619df03207e6?w=600&auto=format&fit=crop&q=80',
          'created_at': Timestamp.now(),
        },
        {
          'id': 'intake',
          'name': 'Air Induction & Intake',
          'description': 'High-flow air filters, cold air intake systems and boxes',
          'icon_name': 'air',
          'parts_count': 2,
          'image_url':
              'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=600&auto=format&fit=crop&q=80',
          'created_at': Timestamp.now(),
        },
        {
          'id': 'engine',
          'name': 'Engine Mechanical & Induction',
          'description': 'Forced induction turbos, spark plugs and core internals',
          'icon_name': 'settings_suggest',
          'parts_count': 1,
          'image_url':
              'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=600&auto=format&fit=crop&q=80',
          'created_at': Timestamp.now(),
        },
        {
          'id': 'suspension',
          'name': 'Suspension & Steering',
          'description': 'Coilovers, dampers, sway bars and tie rods',
          'icon_name': 'swap_vert',
          'parts_count': 1,
          'image_url':
              'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=600&auto=format&fit=crop&q=80',
          'created_at': Timestamp.now(),
        },
        {
          'id': 'filters',
          'name': 'Filters & Maintenance',
          'description': 'Oil filters, biofunctional cabin filters and fuel filters',
          'icon_name': 'fact_check',
          'parts_count': 1,
          'image_url':
              'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=600&auto=format&fit=crop&q=80',
          'created_at': Timestamp.now(),
        },
      ];

      for (final cat in categories) {
        batch.set(_categoriesCol.doc(cat['id'] as String), cat);
      }

      // Seed standard verified SKUs
      final parts = [
        {
          'category_id': 'brakes',
          'category': 'Brakes & Braking Systems',
          'part_name': 'Brembo Ceramic Front Brake Pads',
          'part_number': 'BRM-CC-911',
          'oem_cross_ref': '992-351-405',
          'fitment': 'Porsche 911 Carrera (992), BMW M3/M4 (G80/G82)',
          'position': 'Front Axle Set',
          'spec_tag': 'Standard Spec',
          'partner_shops_count': 14,
          'price': 18500.0,
          'stock_quantity': 25,
          'is_in_stock': true,
          'image_url':
              'https://images.unsplash.com/photo-1600790142055-619df03207e6?w=600&auto=format&fit=crop&q=80',
          'created_at': Timestamp.now(),
        },
        {
          'category_id': 'brakes',
          'category': 'Brakes & Braking Systems',
          'part_name': 'StopTech Steel Braided Brake Lines',
          'part_number': 'ST-BL-G82',
          'oem_cross_ref': 'DOT-FMVSS-106',
          'fitment': 'BMW M2/M3/M4 (F87/G80/G82)',
          'position': 'DOT Compliant 4-Pack',
          'spec_tag': 'High Temp Teflon',
          'partner_shops_count': 8,
          'price': 14200.0,
          'stock_quantity': 18,
          'is_in_stock': true,
          'image_url':
              'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=600&auto=format&fit=crop&q=80',
          'created_at': Timestamp.now(),
        },
        {
          'category_id': 'brakes',
          'category': 'Brakes & Braking Systems',
          'part_name': 'Brembo GT 6-Piston Caliper Kit',
          'part_number': 'BRM-GT-6P',
          'oem_cross_ref': '1N1-9002A',
          'fitment': 'Audi RS3 / TT-RS (8V/8S), VW Golf R (Mk7/Mk8)',
          'position': '380mm Monobloc',
          'spec_tag': 'Specialty Order',
          'partner_shops_count': 4,
          'price': 85000.0,
          'stock_quantity': 6,
          'is_in_stock': true,
          'image_url':
              'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=600&auto=format&fit=crop&q=80',
          'created_at': Timestamp.now(),
        },
        {
          'category_id': 'brakes',
          'category': 'Brakes & Braking Systems',
          'part_name': 'EBC Yellowstuff High Friction Pads',
          'part_number': 'EBC-DP-400',
          'oem_cross_ref': 'DP41591R',
          'fitment': 'Mercedes-AMG A45 / C63 (W205)',
          'position': 'Track & Street',
          'spec_tag': 'High Thermal',
          'partner_shops_count': 11,
          'price': 16800.0,
          'stock_quantity': 14,
          'is_in_stock': true,
          'image_url':
              'https://images.unsplash.com/photo-1600790142055-619df03207e6?w=600&auto=format&fit=crop&q=80',
          'created_at': Timestamp.now(),
        },
        {
          'category_id': 'intake',
          'category': 'Air Induction & Intake',
          'part_name': 'K&N High-Flow Drop-In Air Filter',
          'part_number': 'KN-33-2484',
          'oem_cross_ref': '13717619267',
          'fitment': 'BMW 3-Series (F30/G20), 4-Series (F32/G22)',
          'position': 'Airbox Drop-In',
          'spec_tag': 'Standard Spec',
          'partner_shops_count': 16,
          'price': 8900.0,
          'stock_quantity': 30,
          'is_in_stock': true,
          'image_url':
              'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=600&auto=format&fit=crop&q=80',
          'created_at': Timestamp.now(),
        },
        {
          'category_id': 'intake',
          'category': 'Air Induction & Intake',
          'part_name': 'Eventuri Gloss Carbon Fiber Intake',
          'part_number': 'EVE-G8X-CF',
          'oem_cross_ref': 'EVE-G8X-INT-V2',
          'fitment': 'BMW M3/M4 (G80/G82)',
          'position': 'Dual Carbon Housings',
          'spec_tag': 'Specialty Order',
          'partner_shops_count': 5,
          'price': 98000.0,
          'stock_quantity': 4,
          'is_in_stock': true,
          'image_url':
              'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=600&auto=format&fit=crop&q=80',
          'created_at': Timestamp.now(),
        },
        {
          'category_id': 'engine',
          'category': 'Engine Mechanical & Induction',
          'part_name': 'NGK Laser Iridium Spark Plugs (Set of 6)',
          'part_number': 'NGK-SILZKBR8',
          'oem_cross_ref': '12120039664',
          'fitment': 'BMW B58 / S58 (M340i, Supra, M3/M4)',
          'position': 'Spark Ignition Pack',
          'spec_tag': 'Standard Spec',
          'partner_shops_count': 19,
          'price': 11400.0,
          'stock_quantity': 40,
          'is_in_stock': true,
          'image_url':
              'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=600&auto=format&fit=crop&q=80',
          'created_at': Timestamp.now(),
        },
        {
          'category_id': 'suspension',
          'category': 'Suspension & Steering',
          'part_name': 'KW Variant 3 Inox-Line Coilovers',
          'part_number': 'KW-35220087',
          'oem_cross_ref': 'KW-V3-992',
          'fitment': 'Porsche 911 (992) Carrera / 4S',
          'position': '4-Corner Damping',
          'spec_tag': 'Track & Street',
          'partner_shops_count': 7,
          'price': 125000.0,
          'stock_quantity': 5,
          'is_in_stock': true,
          'image_url':
              'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=600&auto=format&fit=crop&q=80',
          'created_at': Timestamp.now(),
        },
        {
          'category_id': 'filters',
          'category': 'Filters & Maintenance',
          'part_name': 'Mann FreciousPlus Biofunctional Cabin Filter',
          'part_number': 'FP-26-009',
          'oem_cross_ref': '64119237555',
          'fitment': 'Volkswagen Golf 7/8, Audi A3, Seat Leon',
          'position': 'HVAC Cabin Filter',
          'spec_tag': 'Standard Spec',
          'partner_shops_count': 22,
          'price': 4200.0,
          'stock_quantity': 50,
          'is_in_stock': true,
          'image_url':
              'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=600&auto=format&fit=crop&q=80',
          'created_at': Timestamp.now(),
        },
      ];

      for (final part in parts) {
        batch.set(_partsCol.doc(), part);
      }

      await batch.commit();
    } catch (_) {
      // Best-effort initialization
    }
  }
}
