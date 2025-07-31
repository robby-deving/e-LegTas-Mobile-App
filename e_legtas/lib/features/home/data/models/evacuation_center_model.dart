// models/evacuation_center_model.dart
class EvacuationCenterModel {
  final int id;
  final String name;
  final String address;
  final int barangayId;
  final double latitude;
  final double longitude;
  final String ecStatus;
  final String category;
  final int? campManagerId; // Nullable
  final int createdBy;
  final String createdAt;
  final String? updatedAt; // Nullable
  final String barangayName;
  final String? campManagerName; // Nullable
  final String? campManagerPhoneNumber; // Nullable

  EvacuationCenterModel({
    required this.id,
    required this.name,
    required this.address,
    required this.barangayId,
    required this.latitude,
    required this.longitude,
    required this.ecStatus,
    required this.category,
    this.campManagerId, // No 'required' for nullable
    required this.createdBy,
    required this.createdAt,
    this.updatedAt, // No 'required' for nullable
    required this.barangayName,
    this.campManagerName, // No 'required' for nullable
    this.campManagerPhoneNumber, // No 'required' for nullable
  });

  factory EvacuationCenterModel.fromJson(Map<String, dynamic> json) {
    return EvacuationCenterModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      barangayId: json['barangay_id'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      ecStatus: json['ec_status'],
      category: json['category'],
      campManagerId: json['camp_manager_id'], // Already null-safe for int?
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'], // Already null-safe for String?
      barangayName: json['barangay_name'],
      campManagerName: json['camp_manager_name'], // Already null-safe for String?
      campManagerPhoneNumber: json['camp_manager_phone_number'], // Already null-safe for String?
    );
  }
}