import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../services/location_service.dart';
import '../models/parking_spot.dart';

/// Real map widget using OpenStreetMap with GPS functionality
class RealMapWidget extends StatefulWidget {
  final List<ParkingSpot> parkingSpots;
  final Function(ParkingSpot)? onMarkerTap;
  final double height;
  final ValueListenable<double>? uiHideProgressListenable;

  const RealMapWidget({
    super.key,
    required this.parkingSpots,
    this.onMarkerTap,
    this.height = 400,
    this.uiHideProgressListenable,
  });

  @override
  State<RealMapWidget> createState() => _RealMapWidgetState();
}

class _RealMapWidgetState extends State<RealMapWidget> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  List<LatLng> _parkingLocations = [];
  bool _isLoading = true;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Request location permission
      _locationPermissionGranted = await LocationService.instance.requestLocationPermission();
      
      LatLng centerLocation;
      
      if (_locationPermissionGranted) {
        // Try to get current location
        final location = await LocationService.instance.getCurrentLocation();
        if (location != null) {
          _currentLocation = location;
          centerLocation = location;
        } else {
          centerLocation = LocationService.instance.getDefaultLocation();
        }
      } else {
        centerLocation = LocationService.instance.getDefaultLocation();
      }

      // Generate mock parking locations around the center
      _parkingLocations = LocationService.instance.generateMockParkingLocations(
        centerLocation,
        count: widget.parkingSpots.length,
      );

      setState(() {
        _isLoading = false;
      });

      // Move map to center location
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(centerLocation, 14.0);
      });
    } catch (e) {
      print('Error initializing map: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: widget.height,
        color: const Color(0xFFE8E0D8),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Container(
      height: widget.height,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? LocationService.instance.getDefaultLocation(),
              initialZoom: 14.0,
              minZoom: 10.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // OpenStreetMap tile layer (completely free)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.smart_park_connect',
                maxZoom: 19,
              ),
              
              // Current location marker
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              
              // Parking spot markers
              MarkerLayer(
                markers: _parkingLocations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final location = entry.value;
                  final spot = index < widget.parkingSpots.length 
                      ? widget.parkingSpots[index] 
                      : widget.parkingSpots.first;
                  
                  return Marker(
                    point: location,
                    width: 60,
                    height: 80,
                    child: GestureDetector(
                      onTap: () => widget.onMarkerTap?.call(spot),
                      child: Column(
                        children: [
                          // Price bubble
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '₹${spot.pricePerHour}/hr',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Parking marker
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: spot.isAvailable 
                                  ? AppColors.primary 
                                  : AppColors.error,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: (spot.isAvailable 
                                      ? AppColors.primary 
                                      : AppColors.error).withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_parking,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          
          // Map controls (hide as sheet expands)
          if (widget.uiHideProgressListenable == null)
            _buildControls(0)
          else
            ValueListenableBuilder<double>(
              valueListenable: widget.uiHideProgressListenable!,
              builder: (context, progress, _) => _buildControls(progress),
            ),
          
          // Location permission banner
          if (!_locationPermissionGranted)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_off,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Enable location for better experience',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _requestLocationPermission,
                      child: Text(
                        'Enable',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _goToCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 16.0);
    } else {
      final location = await LocationService.instance.getCurrentLocation();
      if (location != null) {
        setState(() {
          _currentLocation = location;
        });
        _mapController.move(location, 16.0);
      }
    }
  }

  void _requestLocationPermission() async {
    final granted = await LocationService.instance.requestLocationPermission();
    if (granted) {
      setState(() {
        _locationPermissionGranted = true;
      });
      _initializeMap();
    }
  }

  Widget _buildControls(double progress) {
    return Positioned(
      top: 120,
      right: 16,
      child: IgnorePointer(
        ignoring: progress > 0.95,
        child: Opacity(
          opacity: 1 - progress,
          child: Transform.translate(
            offset: Offset(0, -20 * progress),
            child: Column(
              children: [
                if (_locationPermissionGranted)
                  FloatingActionButton.small(
                    heroTag: 'location',
                    onPressed: _goToCurrentLocation,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.my_location,
                      color: AppColors.primary,
                    ),
                  ),
                const SizedBox(height: 20),
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom + 1);
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.add,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom - 1);
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.remove,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
