import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/partner_application_model.dart';

class ApprovalsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _approvalsCol =>
      _firestore.collection('partner_applications');

  Stream<List<PartnerApplicationModel>> getApplicationsStream(String status) {
    return _approvalsCol
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => PartnerApplicationModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> updateApplicationStatus(String id, String newStatus) async {
    await _approvalsCol.doc(id).update({
      'status': newStatus,
      'updated_at': Timestamp.now(),
    });
  }

  Future<void> seedInitialApplicationsIfEmpty() async {
    try {
      final snapshot = await _approvalsCol.limit(1).get();
      if (snapshot.docs.isNotEmpty) return;

      final batch = _firestore.batch();

      final initialList = [
        {
          'name': 'Apex Precision Autocare',
          'type': 'garage',
          'category_tag': 'GARAGE • Oil & Scanner',
          'address': '9450 Wilshire Blvd, Beverly Hills, CA',
          'contact_person': 'Marco Rossi',
          'phone': '+1 (310) 555-0192',
          'specs_summary': 'Scanner Diagnostics & Certified Oil Service (4 Bays)',
          'city_badge': 'Beverly Hills',
          'specs_badge': '4 Lift Bays Active',
          'image_url':
              'https://images.unsplash.com/photo-1613214149922-f1809c99b414?w=600&auto=format&fit=crop&q=80',
          'status': 'pending',
          'created_at': Timestamp.now(),
        },
        {
          'name': 'MotorWerks Performance Parts',
          'type': 'parts_shop',
          'category_tag': 'PARTS SHOP • 7-Day Pickup',
          'address': '1420 Olympic Blvd, Los Angeles, CA',
          'contact_person': 'David Chen',
          'phone': '+1 (213) 555-8831',
          'specs_summary': '85 Predefined SKUs in stock (Brakes, Intake, Fluids)',
          'city_badge': 'Los Angeles',
          'specs_badge': '85 Verified SKUs',
          'image_url':
              'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=600&auto=format&fit=crop&q=80',
          'status': 'pending',
          'created_at': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 3))),
        },
        {
          'name': 'Silverlake Autocenter & Diagnostics',
          'type': 'garage',
          'category_tag': 'GARAGE • Scanner & Inspection',
          'address': '2814 Sunset Blvd, Silver Lake, CA',
          'contact_person': 'Sam Jenkins',
          'phone': '+1 (323) 555-4419',
          'specs_summary': 'Euro & Domestic Multi-point Inspection, OBD-II Rig',
          'city_badge': 'Silver Lake',
          'specs_badge': 'OBD-II / CAN Telemetry',
          'image_url':
              'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=600&auto=format&fit=crop&q=80',
          'status': 'pending',
          'created_at': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 12))),
        },
        {
          'name': 'EuroParts Depot',
          'type': 'parts_shop',
          'category_tag': 'PARTS SHOP • OEM Specialist',
          'address': '780 E 1st St, Santa Ana, CA',
          'contact_person': 'Elena Rostova',
          'phone': '+1 (714) 555-2290',
          'specs_summary': 'BMW • Audi • Porsche Genuine OEM Spares',
          'city_badge': 'Santa Ana',
          'specs_badge': 'OEM Direct Partner',
          'image_url':
              'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=600&auto=format&fit=crop&q=80',
          'status': 'pending',
          'created_at': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        },
      ];

      for (final app in initialList) {
        batch.set(_approvalsCol.doc(), app);
      }

      await batch.commit();
    } catch (_) {}
  }
}
