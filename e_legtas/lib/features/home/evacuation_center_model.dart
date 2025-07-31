// models/evacuation_center_model.dart
class EvacuationCenter {
  final int id;
  final String name;
  final String address;
  final int barangayId;
  final double latitude;
  final double longitude;
  final String ecStatus;
  final String category;
  final int? campManagerId;
  final int createdBy;
  final String createdAt;
  final String? updatedAt;
  final String barangayName;
  final String? campManagerName;
  final String? campManagerPhoneNumber;

  EvacuationCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.barangayId,
    required this.latitude,
    required this.longitude,
    required this.ecStatus,
    required this.category,
    required this.campManagerId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.barangayName,
    required this.campManagerName,
    required this.campManagerPhoneNumber,
  });

  factory EvacuationCenter.fromJson(Map<String, dynamic> json) {
    return EvacuationCenter(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      barangayId: json['barangay_id'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      ecStatus: json['ec_status'],
      category: json['category'],
      campManagerId: json['camp_manager_id'],
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      barangayName: json['barangay_name'],
      campManagerName: json['camp_manager_name'],
      campManagerPhoneNumber: json['camp_manager_phone_number'],
    );
  }
}
