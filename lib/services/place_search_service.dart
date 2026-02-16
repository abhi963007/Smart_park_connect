import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model for a place search result
class PlaceResult {
  final String placeId;
  final String displayName;
  final String name;
  final String type;
  final double lat;
  final double lon;
  final String? road;
  final String? city;
  final String? state;
  final String? country;

  PlaceResult({
    required this.placeId,
    required this.displayName,
    required this.name,
    required this.type,
    required this.lat,
    required this.lon,
    this.road,
    this.city,
    this.state,
    this.country,
  });

  LatLng get latLng => LatLng(lat, lon);

  /// Short subtitle built from address parts
  String get subtitle {
    final parts = <String>[];
    if (road != null && road!.isNotEmpty) parts.add(road!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    return parts.isEmpty ? displayName : parts.join(', ');
  }

  /// Primary title – use the short name, fall back to first part of displayName
  String get title {
    if (name.isNotEmpty) return name;
    return displayName.split(',').first.trim();
  }

  factory PlaceResult.fromNominatim(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};
    return PlaceResult(
      placeId: json['place_id'].toString(),
      displayName: json['display_name'] ?? '',
      name: json['name'] ??
          json['display_name']?.toString().split(',').first.trim() ??
          '',
      type: json['type'] ?? '',
      lat: double.tryParse(json['lat'].toString()) ?? 0,
      lon: double.tryParse(json['lon'].toString()) ?? 0,
      road: address['road'] ?? address['suburb'] ?? address['neighbourhood'],
      city: address['city'] ??
          address['town'] ??
          address['village'] ??
          address['county'],
      state: address['state'],
      country: address['country'],
    );
  }

  Map<String, dynamic> toJson() => {
        'placeId': placeId,
        'displayName': displayName,
        'name': name,
        'type': type,
        'lat': lat,
        'lon': lon,
        'road': road,
        'city': city,
        'state': state,
        'country': country,
      };

  factory PlaceResult.fromJson(Map<String, dynamic> json) => PlaceResult(
        placeId: json['placeId'] ?? '',
        displayName: json['displayName'] ?? '',
        name: json['name'] ?? '',
        type: json['type'] ?? '',
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lon: (json['lon'] as num?)?.toDouble() ?? 0,
        road: json['road'],
        city: json['city'],
        state: json['state'],
        country: json['country'],
      );
}

/// Service that queries OpenStreetMap Nominatim for real place search.
/// Completely free – no API key required.
class PlaceSearchService {
  static PlaceSearchService? _instance;
  static PlaceSearchService get instance =>
      _instance ??= PlaceSearchService._();
  PlaceSearchService._();

  static const _baseUrl = 'https://nominatim.openstreetmap.org';
  static const _recentKey = 'recent_searches_v2';
  static const int _maxRecent = 10;

  /// Search places by query string.
  /// [viewbox] can bias results to a bounding box (lon1,lat1,lon2,lat2).
  /// [nearLatLng] biases results near a location.
  Future<List<PlaceResult>> search(
    String query, {
    LatLng? nearLatLng,
    int limit = 8,
  }) async {
    if (query.trim().isEmpty) return [];

    final params = <String, String>{
      'q': query.trim(),
      'format': 'json',
      'addressdetails': '1',
      'limit': limit.toString(),
      'accept-language': 'en',
    };

    // Bias results near user location if available
    if (nearLatLng != null) {
      const offset = 0.5; // ~50 km bias box
      params['viewbox'] =
          '${nearLatLng.longitude - offset},${nearLatLng.latitude - offset},'
          '${nearLatLng.longitude + offset},${nearLatLng.latitude + offset}';
      params['bounded'] = '0'; // prefer but don't restrict
    }

    try {
      final uri =
          Uri.parse('$_baseUrl/search').replace(queryParameters: params);
      final response = await http.get(uri, headers: {
        'User-Agent': 'SmartParkConnect/1.0 (parking-app)',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((e) => PlaceResult.fromNominatim(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('PlaceSearchService.search error: $e');
    }
    return [];
  }

  /// Reverse-geocode a lat/lng to a place name.
  Future<PlaceResult?> reverseGeocode(LatLng location) async {
    try {
      final uri = Uri.parse('$_baseUrl/reverse').replace(queryParameters: {
        'lat': location.latitude.toString(),
        'lon': location.longitude.toString(),
        'format': 'json',
        'addressdetails': '1',
        'accept-language': 'en',
      });
      final response = await http.get(uri, headers: {
        'User-Agent': 'SmartParkConnect/1.0 (parking-app)',
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data.containsKey('error')) return null;
        return PlaceResult.fromNominatim(data);
      }
    } catch (e) {
      print('PlaceSearchService.reverseGeocode error: $e');
    }
    return null;
  }

  // ──────────── Recent searches (persisted) ────────────

  Future<List<PlaceResult>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_recentKey) ?? [];
      return raw
          .map((s) =>
              PlaceResult.fromJson(json.decode(s) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addRecentSearch(PlaceResult place) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_recentKey) ?? [];

      // Remove duplicate if exists
      raw.removeWhere((s) {
        try {
          final decoded = json.decode(s) as Map<String, dynamic>;
          return decoded['placeId'] == place.placeId;
        } catch (_) {
          return false;
        }
      });

      // Insert at front
      raw.insert(0, json.encode(place.toJson()));

      // Keep max
      if (raw.length > _maxRecent) raw.removeRange(_maxRecent, raw.length);

      await prefs.setStringList(_recentKey, raw);
    } catch (_) {}
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentKey);
  }
}
