/// Centralized Firebase Configuration & Values File
/// You can update this file regularly as your Firestore schema and values evolve.
class FirebaseConstants {
  FirebaseConstants._();

  // Firebase Project
  static const String projectId = 'carfix-33875';

  // ----------------------------------------------------
  // FIRESTORE COLLECTIONS
  // ----------------------------------------------------
  static const String colUsers = 'users';
  static const String colSpareParts = 'spare_parts';
  static const String colGarages = 'garages';
  static const String colAppointments = 'appointments';
  static const String colDiagnosticReports = 'diagnostic_reports';
  static const String colCategories = 'categories';
  static const String colOilBrands = 'oil_brands';
  static const String colOilFormulas = 'oil_formulas';
  static const String colAppConfig = 'app_config';
  static const String colAuditLogs = 'audit_logs';

  // ----------------------------------------------------
  // USER ROLES
  // ----------------------------------------------------
  static const String roleAdmin = 'admin';
  static const String roleClient = 'client';
  static const String roleSparePartsDealer = 'spare_parts_dealer';
  static const String roleOilChangeGarage = 'oil_change_garage';
  static const String roleScannerGarage = 'scanner_garage';

  static const List<String> allRoles = [
    roleAdmin,
    roleClient,
    roleSparePartsDealer,
    roleOilChangeGarage,
    roleScannerGarage,
  ];

  // ----------------------------------------------------
  // APPOINTMENT STATUSES
  // ----------------------------------------------------
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  static const String statusRejected = 'rejected';

  // ----------------------------------------------------
  // APPOINTMENT SERVICE TYPES
  // ----------------------------------------------------
  static const String serviceOilChange = 'oil_change';
  static const String serviceScannerDiagnosis = 'scanner_diagnosis';
  static const String serviceGeneralCheckup = 'general_checkup';

  // ----------------------------------------------------
  // COMMON DOCUMENT FIELD NAMES
  // ----------------------------------------------------
  static const String fieldId = 'id';
  static const String fieldUid = 'uid';
  static const String fieldEmail = 'email';
  static const String fieldFullName = 'full_name';
  static const String fieldPhoneNumber = 'phone_number';
  static const String fieldRole = 'role';
  static const String fieldAvatarUrl = 'avatar_url';
  static const String fieldIsActive = 'is_active';
  static const String fieldCreatedAt = 'created_at';
  static const String fieldUpdatedAt = 'updated_at';

  // Garage specific fields
  static const String fieldGarageName = 'garage_name';
  static const String fieldGarageType = 'garage_type';
  static const String fieldAddress = 'address';
  static const String fieldCity = 'city';
  static const String fieldLatitude = 'latitude';
  static const String fieldLongitude = 'longitude';
  static const String fieldOpeningHours = 'opening_hours';
  static const String fieldRating = 'rating';

  // Spare parts specific fields
  static const String fieldPartName = 'part_name';
  static const String fieldPartNumber = 'part_number';
  static const String fieldCategory = 'category';
  static const String fieldCategoryId = 'category_id';
  static const String fieldOemCrossRef = 'oem_cross_ref';
  static const String fieldFitment = 'fitment';
  static const String fieldCarMake = 'car_make';
  static const String fieldCarModel = 'car_model';
  static const String fieldCarYear = 'car_year';
  static const String fieldPrice = 'price';
  static const String fieldStockQuantity = 'stock_quantity';
  static const String fieldPartnerShopsCount = 'partner_shops_count';
  static const String fieldSpecTag = 'spec_tag';
  static const String fieldPosition = 'position';
  static const String fieldImageUrl = 'image_url';
  static const String fieldDealerId = 'dealer_id';
  static const String fieldDealerName = 'dealer_name';

  // Category / System specific fields
  static const String fieldCategoryName = 'name';
  static const String fieldCategoryIcon = 'icon_name';
  static const String fieldCategoryDescription = 'description';
  static const String fieldCategoryPartsCount = 'parts_count';

  // ----------------------------------------------------
  // APP CONFIG & VERSION
  // ----------------------------------------------------
  static const String appVersion = '2.4.0';
  static const String appName = 'CARfix';
  static const String appTagline = 'Precision Automotive Care';
  static const String appSubtagline = 'Expert Repair & Diagnostics';
  static const String certifiedNetworkText = 'Certified Automotive Network';
}
