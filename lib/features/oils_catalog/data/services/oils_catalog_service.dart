import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../models/oil_brand_model.dart';
import '../models/oil_formula_model.dart';

class OilsCatalogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _brandsCol =>
      _firestore.collection(FirebaseConstants.colOilBrands);

  CollectionReference<Map<String, dynamic>> get _formulasCol =>
      _firestore.collection(FirebaseConstants.colOilFormulas);

  /// Stream of all registered brands ordered by name
  Stream<List<OilBrandModel>> getBrandsStream() {
    return _brandsCol.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return OilBrandModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Stream of formulas for a specific brand
  Stream<List<OilFormulaModel>> getFormulasForBrandStream(String brandId) {
    return _formulasCol
        .where('brand_id', isEqualTo: brandId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OilFormulaModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Stream of all formulas (for global telemetry stats)
  Stream<List<OilFormulaModel>> getAllFormulasStream() {
    return _formulasCol.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return OilFormulaModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Add a new brand
  Future<void> addBrand(OilBrandModel brand) async {
    final docRef = brand.id.isNotEmpty
        ? _brandsCol.doc(brand.id)
        : _brandsCol.doc();
    await docRef.set(brand.toMap());
  }

  /// Add an oil formula and increment brand's formula count
  Future<void> addOilFormula(OilFormulaModel formula) async {
    final docRef = _formulasCol.doc();
    await docRef.set(formula.toMap());

    // Increment count on brand
    final brandRef = _brandsCol.doc(formula.brandId);
    await brandRef.update({
      'oil_count': FieldValue.increment(1),
    });
  }

  /// Delete a brand and all its associated formulas
  Future<void> deleteBrand(String brandId) async {
    // 1. Delete all formulas for this brand
    final formulasSnapshot =
        await _formulasCol.where('brand_id', isEqualTo: brandId).get();
    final batch = _firestore.batch();
    for (final doc in formulasSnapshot.docs) {
      batch.delete(doc.reference);
    }
    // 2. Delete the brand document
    batch.delete(_brandsCol.doc(brandId));
    await batch.commit();
  }

  /// Delete an oil formula
  Future<void> deleteOilFormula(String formulaId, String brandId) async {
    await _formulasCol.doc(formulaId).delete();
    final brandRef = _brandsCol.doc(brandId);
    await brandRef.update({
      'oil_count': FieldValue.increment(-1),
    });
  }

  /// Seeds default verified brands & formulas if Firestore is currently empty
  Future<void> seedInitialDataIfEmpty() async {
    try {
      final existing = await _brandsCol.limit(1).get();
      if (existing.docs.isNotEmpty) {
        return; // Already populated
      }

      final defaultBrands = [
        const OilBrandModel(
          id: 'mobil_1',
          name: 'Mobil 1',
          manufacturer: 'ExxonMobil',
          tier: 'OEM Certified',
          oilCount: 4,
          logoUrl: 'https://images.unsplash.com/photo-1598971861713-54ad16a7e72e?w=200&auto=format&fit=crop&q=80',
        ),
        const OilBrandModel(
          id: 'castrol',
          name: 'Castrol',
          manufacturer: 'BP Lubricants',
          tier: 'OEM Partner',
          oilCount: 2,
          logoUrl: 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=200&auto=format&fit=crop&q=80',
        ),
        const OilBrandModel(
          id: 'motul',
          name: 'Motul',
          manufacturer: 'Motul Group',
          tier: 'Motorsport High-Spec',
          oilCount: 1,
          logoUrl: 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=200&auto=format&fit=crop&q=80',
        ),
        const OilBrandModel(
          id: 'liqui_moly',
          name: 'Liqui Moly',
          manufacturer: 'Liqui Moly GmbH',
          tier: 'Euro OEM',
          oilCount: 1,
          logoUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=200&auto=format&fit=crop&q=80',
        ),
        const OilBrandModel(
          id: 'valvoline',
          name: 'Valvoline',
          manufacturer: 'Valvoline Global',
          tier: 'Aftermarket Spec',
          oilCount: 1,
          logoUrl: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=200&auto=format&fit=crop&q=80',
        ),
      ];

      final defaultFormulas = [
        const OilFormulaModel(
          id: 'formula_mobil1_1',
          brandId: 'mobil_1',
          brandName: 'Mobil 1',
          viscosity: '0W-40',
          title: 'Mobil 1 FS European Formula',
          composition: 'Full Synthetic',
          oemSpecs: 'MB 229.5, Porsche A40, VW 502 00',
          categoryTag: 'Euro Spec',
          activeGaragesCount: 32,
        ),
        const OilFormulaModel(
          id: 'formula_mobil1_2',
          brandId: 'mobil_1',
          brandName: 'Mobil 1',
          viscosity: '5W-30',
          title: 'Mobil 1 ESP Protection',
          composition: 'Full Synthetic',
          oemSpecs: 'Emission System Protection • ACEA C3, API SP Low-SAPS',
          categoryTag: 'Clean Diesel',
          activeGaragesCount: 24,
        ),
        const OilFormulaModel(
          id: 'formula_mobil1_3',
          brandId: 'mobil_1',
          brandName: 'Mobil 1',
          viscosity: '5W-30',
          title: 'Mobil 1 Super Synthetic Blend',
          composition: 'Synthetic Blend',
          oemSpecs: 'High Performance Semi-Synthetic • API SN PLUS, ILSAC GF-5',
          categoryTag: 'Standard',
          activeGaragesCount: 18,
        ),
        const OilFormulaModel(
          id: 'formula_mobil1_4',
          brandId: 'mobil_1',
          brandName: 'Mobil 1',
          viscosity: '0W-20',
          title: 'Mobil 1 Extended Performance',
          composition: 'Full Synthetic',
          oemSpecs: 'Guaranteed 20,000 Mile Protection • Dexos1 Gen3, API SP',
          categoryTag: 'Ultra-Low Vis',
          activeGaragesCount: 15,
        ),
        const OilFormulaModel(
          id: 'formula_castrol_1',
          brandId: 'castrol',
          brandName: 'Castrol',
          viscosity: '5W-30',
          title: 'Castrol EDGE Advanced Full Syn',
          composition: 'Full Synthetic',
          oemSpecs: 'Fluid Titanium Technology • API SP, ILSAC GF-6',
          categoryTag: 'Active',
          activeGaragesCount: 26,
        ),
        const OilFormulaModel(
          id: 'formula_castrol_2',
          brandId: 'castrol',
          brandName: 'Castrol',
          viscosity: '10W-40',
          title: 'Castrol GTX Ultraclean',
          composition: 'Synthetic Blend',
          oemSpecs: 'Double Action Sludge Defense • ACEA A3/B4',
          categoryTag: 'Active',
          activeGaragesCount: 19,
        ),
        const OilFormulaModel(
          id: 'formula_motul_1',
          brandId: 'motul',
          brandName: 'Motul',
          viscosity: '10W-40',
          title: 'Motul 300V Chrono Racing',
          composition: 'Racing Ester',
          oemSpecs: 'Ester Core® Technology • High shear stability motorsport',
          categoryTag: 'Motorsport',
          activeGaragesCount: 14,
        ),
        const OilFormulaModel(
          id: 'formula_liqui_1',
          brandId: 'liqui_moly',
          brandName: 'Liqui Moly',
          viscosity: '5W-30',
          title: 'Top Tec 4200 Longlife III',
          composition: 'Full Synthetic',
          oemSpecs: 'Audi/VW 504 00 / 507 00, BMW Longlife-04',
          categoryTag: 'Euro OEM',
          activeGaragesCount: 22,
        ),
        const OilFormulaModel(
          id: 'formula_valvoline_1',
          brandId: 'valvoline',
          brandName: 'Valvoline',
          viscosity: '5W-20',
          title: 'Valvoline SynPower Full Syn',
          composition: 'Full Synthetic',
          oemSpecs: 'High Temperature Protection • API SP, Dexos1',
          categoryTag: 'Active',
          activeGaragesCount: 17,
        ),
      ];

      final batch = _firestore.batch();

      for (final brand in defaultBrands) {
        batch.set(_brandsCol.doc(brand.id), brand.toMap());
      }

      for (final formula in defaultFormulas) {
        batch.set(_formulasCol.doc(formula.id), formula.toMap());
      }

      await batch.commit();
    } catch (_) {
      // Ignored if offline or permissions restrict initial write
    }
  }
}
