import 'package:e_legtas/features/home/data/datasources/evacuation_center_remote_datasource.dart';
import 'package:e_legtas/features/home/domain/entities/evacuation_center.dart';
import 'package:e_legtas/features/home/domain/repositories/evacuation_center_repository.dart';

class EvacuationCenterRepositoryImpl implements EvacuationCenterRepository {
  final EvacuationCenterRemoteDataSource remoteDataSource;

  EvacuationCenterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<EvacuationCenter>> getEvacuationCenters() async {
    try {
      final models = await remoteDataSource.fetchDetailedMapData();
      
      return models.map((model) => EvacuationCenter.fromModel(model)).toList();
    } catch (e) {
      // Handle errors, e.g., log them or throw a more specific domain exception
      rethrow;
    }
  }
}