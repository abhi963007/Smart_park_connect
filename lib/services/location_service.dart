import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';

/// Service to handle location-related functionality
class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  /// Check if location services are enabled and permissions are granted
  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permissions
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  /// Get current location
  Future<LatLng?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Get location stream for real-time updates
  Stream<LatLng> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).map((position) => LatLng(position.latitude, position.longitude));
  }

  /// Calculate distance between two points in meters
  double calculateDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Get a default location (Delhi, India) if GPS is not available
  LatLng getDefaultLocation() {
    return LatLng(28.6139, 77.2090); // New Delhi coordinates
  }

  /// Generate mock parking locations around a center point
  List<LatLng> generateMockParkingLocations(LatLng center, {int count = 10}) {
    final List<LatLng> locations = [];
    final random = DateTime.now().millisecondsSinceEpoch;
    
    for (int i = 0; i < count; i++) {
      // Generate random offset within ~2km radius
      final latOffset = ((random + i * 17) % 1000 - 500) / 100000.0;
      final lngOffset = ((random + i * 23) % 1000 - 500) / 100000.0;
      
      locations.add(LatLng(
        center.latitude + latOffset,
        center.longitude + lngOffset,
      ));
    }
    
    return locations;
  }
}
