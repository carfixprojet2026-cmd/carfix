import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';

class DashboardStats {
  final int clientsCount;
  final int garagesCount;
  final int partsCount;
  final int pendingApprovalsCount;
  final int appointmentsCount;
  final int partHoldsCount;

  const DashboardStats({
    this.clientsCount = 0,
    this.garagesCount = 0,
    this.partsCount = 0,
    this.pendingApprovalsCount = 0,
    this.appointmentsCount = 0,
    this.partHoldsCount = 0,
  });
}

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream aggregating live collection counts from Firestore
  Stream<DashboardStats> getStatsStream() {
    return _firestore.collection(FirebaseConstants.colUsers).snapshots().asyncMap((_) async {
      try {
        final clientsQuery = _firestore
            .collection(FirebaseConstants.colUsers)
            .where(FirebaseConstants.fieldRole, isEqualTo: FirebaseConstants.roleClient)
            .count();

        final garagesQuery = _firestore.collection(FirebaseConstants.colGarages).count();

        final partsQuery = _firestore.collection(FirebaseConstants.colSpareParts).count();

        final pendingApprovalsQuery = _firestore
            .collection(FirebaseConstants.colUsers)
            .where('is_approved', isEqualTo: false)
            .count();

        final appointmentsQuery = _firestore.collection(FirebaseConstants.colAppointments).count();

        final results = await Future.wait([
          clientsQuery.get(),
          garagesQuery.get(),
          partsQuery.get(),
          pendingApprovalsQuery.get(),
          appointmentsQuery.get(),
        ]);

        return DashboardStats(
          clientsCount: results[0].count ?? 0,
          garagesCount: results[1].count ?? 0,
          partsCount: results[2].count ?? 0,
          pendingApprovalsCount: results[3].count ?? 0,
          appointmentsCount: results[4].count ?? 0,
          partHoldsCount: 0,
        );
      } catch (_) {
        // Fallback default stats if collections are empty or offline
        return const DashboardStats();
      }
    });
  }
}
