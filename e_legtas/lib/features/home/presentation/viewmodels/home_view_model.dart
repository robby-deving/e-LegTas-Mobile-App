import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:e_legtas/features/home/domain/entities/evacuation_center.dart';
import 'package:e_legtas/features/home/domain/repositories/evacuation_center_repository.dart';

// 1. Define the State for HomeViewModel
class HomeViewState {
  final LatLng? currentLocation;
  final List<EvacuationCenter> evacuationCenters;
  final List<EvacuationCenter> filteredEvacuationCenters; // For search results
  final bool isLoadingLocation;
  final bool isLoadingEvacuationCenters;
  final String? errorMessage;
  final String? currentSearchQuery; // To keep track of the active search query

  HomeViewState({
    this.currentLocation,
    this.evacuationCenters = const [],
    this.filteredEvacuationCenters = const [], // Initialize empty
    this.isLoadingLocation = true, // Start as true for initial location fetch
    this.isLoadingEvacuationCenters = true, // Start as true for initial EC fetch
    this.errorMessage,
    this.currentSearchQuery, // Initialize null
  });

  // Helper method to create a new state with updated values
  HomeViewState copyWith({
    LatLng? currentLocation,
    List<EvacuationCenter>? evacuationCenters,
    List<EvacuationCenter>? filteredEvacuationCenters,
    bool? isLoadingLocation,
    bool? isLoadingEvacuationCenters,
    String? errorMessage,
    String? currentSearchQuery,
  }) {
    return HomeViewState(
      currentLocation: currentLocation ?? this.currentLocation,
      evacuationCenters: evacuationCenters ?? this.evacuationCenters,
      filteredEvacuationCenters: filteredEvacuationCenters ?? this.filteredEvacuationCenters,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      isLoadingEvacuationCenters: isLoadingEvacuationCenters ?? this.isLoadingEvacuationCenters,
      errorMessage: errorMessage, // Note: Setting errorMessage to null explicitly clears it
      currentSearchQuery: currentSearchQuery,
    );
  }
}

// 2. Define the HomeViewModel (StateNotifier)
class HomeViewModel extends StateNotifier<HomeViewState> {
  final EvacuationCenterRepository _evacuationCenterRepository;

  HomeViewModel(this._evacuationCenterRepository) : super(HomeViewState());

  // Call this method from your provider's initialization or wherever you need to start fetching data
  Future<void> initializeMapData() async {
    // Fetch location first, then evacuation centers
    await _getLocation();
    await fetchEvacuationCenters();
  }

  Future<void> _getLocation() async {
    state = state.copyWith(isLoadingLocation: true, errorMessage: null); // Clear previous errors
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          errorMessage: 'Location services are disabled. Please enable them to use the map.',
          isLoadingLocation: false,
        );
        return;
      }

      // Check location permission status
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          state = state.copyWith(
            errorMessage: 'Location permissions are denied. Please grant them in app settings.',
            isLoadingLocation: false,
          );
          return;
        }
      }

      // If permissions are granted, get the current position
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high, // Use high accuracy for better map experience
        );
        state = state.copyWith(
          currentLocation: LatLng(position.latitude, position.longitude),
          isLoadingLocation: false,
        );
      }
    } catch (e) {
      // Catch any other errors during location fetching
      state = state.copyWith(
        errorMessage: 'Failed to get current location: ${e.toString()}',
        isLoadingLocation: false,
      );
    }
  }

  Future<void> fetchEvacuationCenters() async {
    state = state.copyWith(isLoadingEvacuationCenters: true, errorMessage: null); // Clear previous errors
    try {
      final centers = await _evacuationCenterRepository.getEvacuationCenters();
      state = state.copyWith(
        evacuationCenters: centers,
        filteredEvacuationCenters: centers, // Initially, filtered list is all centers
        isLoadingEvacuationCenters: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load evacuation centers: ${e.toString()}',
        isLoadingEvacuationCenters: false,
      );
    }
  }

  // Search method
  void searchEvacuationCenters(String query) {
    if (query.isEmpty) {
      state = state.copyWith(
        filteredEvacuationCenters: state.evacuationCenters, // Show all if query is empty
        currentSearchQuery: null, // Clear the stored query
      );
      return;
    }

    final lowerCaseQuery = query.toLowerCase();
    final results = state.evacuationCenters.where((center) {
      // Search by name, address, or barangay name
      return center.name.toLowerCase().contains(lowerCaseQuery) ||
             center.address.toLowerCase().contains(lowerCaseQuery) ||
             (center.barangayName?.toLowerCase().contains(lowerCaseQuery) ?? false); // Check for null
    }).toList();

    state = state.copyWith(
      filteredEvacuationCenters: results,
      currentSearchQuery: query, // Store the active query
    );
  }

  void centerMapOnUserTrigger() {
    // This method is still here to demonstrate an action,
    // though the UI directly controls the map via MapController.move.
  }

  // Placeholder for future direction logic
  void getDirection() {
    // Implement logic to open a mapping app for directions
    // e.g., using url_launcher package
    // For now, it's just a placeholder demonstrating interaction.
  }
}