import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:e_legtas/features/home/data/datasources/evacuation_center_remote_datasource.dart';
import 'package:e_legtas/features/home/data/repositories/evacuation_center_repository_impl.dart';
import 'package:e_legtas/features/home/domain/repositories/evacuation_center_repository.dart';
import 'package:e_legtas/features/home/presentation/viewmodels/home_view_model.dart';

// Provides the HTTP client (can be swapped for Dio or another client)
final httpClientProvider = Provider((ref) => http.Client());

// Provides the remote data source
final evacuationCenterRemoteDataSourceProvider = Provider(
  (ref) => EvacuationCenterRemoteDataSource(client: ref.watch(httpClientProvider)),
);

// Provides the repository implementation
final evacuationCenterRepositoryProvider = Provider<EvacuationCenterRepository>(
  (ref) => EvacuationCenterRepositoryImpl(
    remoteDataSource: ref.watch(evacuationCenterRemoteDataSourceProvider),
  ),
);

// Provides the HomeViewModel (the actual state notifier)
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeViewState>(
  (ref) {
    final repository = ref.watch(evacuationCenterRepositoryProvider);
    return HomeViewModel(repository)..initializeMapData(); // Initialize data on creation
  },
);