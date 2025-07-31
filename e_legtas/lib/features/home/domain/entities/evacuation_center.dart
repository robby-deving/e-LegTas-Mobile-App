import 'package:e_legtas/features/home/data/models/evacuation_center_model.dart';

// Represents the core business object, independent of data sources.
// For simple cases, it can be identical to the model.
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
    this.campManagerId,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    required this.barangayName,
    this.campManagerName,
    this.campManagerPhoneNumber,
  });

  // Factory method to convert from model to entity
  factory EvacuationCenter.fromModel(EvacuationCenterModel model) {
    return EvacuationCenter(
      id: model.id,
      name: model.name,
      address: model.address,
      barangayId: model.barangayId,
      latitude: model.latitude,
      longitude: model.longitude,
      ecStatus: model.ecStatus,
      category: model.category,
      campManagerId: model.campManagerId,
      createdBy: model.createdBy,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      barangayName: model.barangayName,
      campManagerName: model.campManagerName,
      campManagerPhoneNumber: model.campManagerPhoneNumber,
    );
  }
}