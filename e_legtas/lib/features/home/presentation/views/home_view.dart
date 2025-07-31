import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_legtas/features/home/presentation/providers/home_view_model_provider.dart';
import 'package:e_legtas/features/home/domain/entities/evacuation_center.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.read(homeViewModelProvider.notifier);

    final MapController mapController = MapController();
    final TextEditingController searchController = TextEditingController(
      text: homeState.currentSearchQuery ?? '', // Pre-fill with current query
    );

    if (homeState.isLoadingLocation || homeState.isLoadingEvacuationCenters) {
      return const Center(child: CircularProgressIndicator());
    }

    if (homeState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                homeState.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  homeViewModel.initializeMapData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (homeState.currentLocation == null) {
      return const Center(
        child: Text('Unable to retrieve your current location. Please check app permissions.'),
      );
    }

    final List<Marker> evacuationCenterMarkers = homeState.filteredEvacuationCenters.map((center) {
      return Marker(
        width: 40,
        height: 40,
        point: LatLng(center.latitude, center.longitude),
        child: Tooltip(
          message: center.name,
          child: GestureDetector(
            onTap: () {
              _showEvacuationCenterDetails(context, center); // Show details on marker tap
            },
            child: SvgPicture.asset(
              'assets/icons/ECMarker.svg', // Your SVG asset for EC markers
              width: 32,
              height: 32,
            ),
          ),
        ),
      );
    }).toList();

    final List<Marker> allMarkers = [
      Marker(
        width: 20,
        height: 20,
        point: homeState.currentLocation!, // User's current location
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0C955B), // A distinct color for user location
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C955B).withAlpha((255 * 0.9).toInt()),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
      ...evacuationCenterMarkers, // Spread (add all) evacuation center markers
    ];

    return Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: homeState.currentLocation!,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all, // Allow all map interactions (pan, zoom)
                ),
                onTap: (tapPosition, latLng) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  FocusScope.of(context).unfocus(); // Dismiss keyboard on map tap
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.e_legtas', // Important for TileLayer
                ),
                MarkerLayer(
                  markers: allMarkers, // Display all markers
                ),
                // You can add more layers here, e.g., Polylines for routes, Polygons for areas.
              ],
            ),
            // Search bar at the top-right - NOW USING POSITIONED DIRECTLY
            SafeArea( // Still good to have SafeArea to avoid notch/status bar
              child: Positioned( // <--- THIS IS THE KEY CHANGE
                top: 24, // Margin from the top
                right: 24, // Margin from the right
                left: 48, // Margin from the left
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for an Evacuation Center',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none, // Remove default border
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    ),
                    onChanged: (query) {
                      print('TextField raw input: "$query"'); // Added for debugging 'locib' issue
                      homeViewModel.searchEvacuationCenters(query);
                    },
                    onSubmitted: (query) {
                      FocusScope.of(context).unfocus(); // Dismiss keyboard
                    },
                  ),
                ),
              ),
            ),

            // Buttons column at bottom-right (without SafeArea as per your last request)
            Positioned(
              bottom: 24, // Padding from the bottom edge
              right: 24, // Padding from the right edge
              child: Column(
                children: [
                  _MapActionButton(
                    iconPath: 'assets/icons/location.svg',
                    onTap: () {
                      if (homeState.currentLocation != null) {
                        mapController.move(homeState.currentLocation!, 15); // Call move on the local controller
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Your current location is not available.')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _MapActionButton(
                    iconPath: 'assets/icons/direction.svg',
                    onTap: () {
                      homeViewModel.getDirection(); // Call ViewModel method
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Direction button clicked (placeholder)')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
    );
  }

  // Helper widget for the map action buttons to reduce repetition
  Widget _MapActionButton({
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      color: Colors.grey,
      dashPattern: const [6, 3],
      strokeWidth: 2,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }

  // Method to show evacuation center details in a modal bottom sheet
  void _showEvacuationCenterDetails(BuildContext context, EvacuationCenter center) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Make background transparent to allow custom shape
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                center.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0C955B), // A nice green color
                ),
              ),
              const SizedBox(height: 8),
              Text(
                center.address,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.category, color: Colors.blueGrey[400], size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Category: ${center.category}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.security, color: Colors.orange[400], size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${center.ecStatus}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              if (center.campManagerName != null && center.campManagerName!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.brown[400], size: 18),
                    const SizedBox(width: 8),
                    Flexible( // Use Flexible to prevent overflow
                      child: Text(
                        'Manager: ${center.campManagerName}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis, // Add ellipsis if text is too long
                      ),
                    ),
                  ],
                ),
              ],
              if (center.campManagerPhoneNumber != null && center.campManagerPhoneNumber!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.blue[400], size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Contact: ${center.campManagerPhoneNumber}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement actual direction logic (e.g., open Google Maps/Waze)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Getting directions to ${center.name} (Not implemented yet)')),
                    );
                    Navigator.pop(context); // Dismiss bottom sheet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C955B), // Use your app's primary color
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}