import 'package:e_legtas/features/home/domain/entities/evacuation_center.dart';

abstract class EvacuationCenterRepository {
  Future<List<EvacuationCenter>> getEvacuationCenters();
}