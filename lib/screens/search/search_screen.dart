import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../services/location_service.dart';
import '../../services/place_search_service.dart';
import '../search/search_results_screen.dart';

/// Search locations screen with live Nominatim suggestions,
/// persisted recent searches, and GPS current-location support.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  // State
  bool _hasText = false;
  bool _isSearching = false;
  String _currentLocationText = 'Using GPS • High accuracy';
  LatLng? _userLocation;
  List<PlaceResult> _suggestions = [];
  List<PlaceResult> _recentSearches = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _searchController.addListener(_onSearchChanged);
    _initLocation();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ──────────── Initialisation ────────────

  Future<void> _initLocation() async {
    try {
      final loc = await LocationService.instance.getCurrentLocation();
      if (loc != null && mounted) {
        setState(() {
          _userLocation = loc;
          _currentLocationText = 'Using GPS • High accuracy';
        });
      } else if (mounted) {
        setState(() => _currentLocationText = 'Location unavailable');
      }
    } catch (_) {
      if (mounted) setState(() => _currentLocationText = 'Location unavailable');
    }
  }

  Future<void> _loadRecentSearches() async {
    final recent = await PlaceSearchService.instance.getRecentSearches();
    if (mounted) setState(() => _recentSearches = recent);
  }

  // ──────────── Search logic ────────────

  void _onSearchChanged() {
    final text = _searchController.text;
    setState(() => _hasText = text.isNotEmpty);

    _debounce?.cancel();
    if (text.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    // Debounce 400ms so we don't spam the API on every keystroke
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await PlaceSearchService.instance.search(
        text,
        nearLatLng: _userLocation,
      );
      if (mounted && _searchController.text == text) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      }
    });
  }

  void _selectPlace(PlaceResult place) {
    // Save to recent searches
    PlaceSearchService.instance.addRecentSearch(place);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(
          query: place.title,
          latitude: place.lat,
          longitude: place.lon,
        ),
      ),
    );
  }

  void _submitSearch(String query) {
    if (query.trim().isEmpty) return;
    // If we already have a matching suggestion, use it
    final match = _suggestions.where(
      (s) => s.title.toLowerCase() == query.trim().toLowerCase(),
    );
    if (match.isNotEmpty) {
      _selectPlace(match.first);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SearchResultsScreen(query: query.trim()),
        ),
      );
    }
  }

  void _useCurrentLocation() async {
    final loc = await LocationService.instance.getCurrentLocation();
    if (loc != null) {
      // Reverse-geocode to get a place name
      final place = await PlaceSearchService.instance.reverseGeocode(loc);
      if (place != null && mounted) {
        _selectPlace(place);
      } else if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SearchResultsScreen(
              query: 'Current Location',
              latitude: loc.latitude,
              longitude: loc.longitude,
            ),
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to get current location. Please check location permissions.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ──────────── Build ────────────

  @override
  Widget build(BuildContext context) {
    final showSuggestions = _hasText && (_suggestions.isNotEmpty || _isSearching);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 1.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              textInputAction: TextInputAction.search,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search location...',
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.textHint,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              onSubmitted: _submitSearch,
                            ),
                          ),
                          if (_hasText)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _focusNode.requestFocus();
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.clear,
                                    color: AppColors.textHint, size: 20),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _focusNode.requestFocus();
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Current Location tile ──
            _buildCurrentLocationTile(),

            // ── Body: suggestions OR recent/popular ──
            Expanded(
              child: showSuggestions
                  ? _buildSuggestionsList()
                  : _buildDefaultContent(),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────── Suggestions list (live from API) ────────────

  Widget _buildSuggestionsList() {
    if (_isSearching && _suggestions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_suggestions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            'No places found',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      itemCount: _suggestions.length + (_isSearching ? 1 : 0),
      itemBuilder: (context, index) {
        // Show a small loading indicator at the bottom while still fetching
        if (index == _suggestions.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              ),
            ),
          );
        }

        final place = _suggestions[index];
        return _buildPlaceTile(place);
      },
    );
  }

  Widget _buildPlaceTile(PlaceResult place) {
    // Pick an icon based on the place type
    IconData icon;
    switch (place.type) {
      case 'city':
      case 'town':
      case 'village':
        icon = Icons.location_city;
        break;
      case 'suburb':
      case 'neighbourhood':
      case 'residential':
        icon = Icons.holiday_village;
        break;
      case 'road':
      case 'highway':
      case 'motorway':
        icon = Icons.route;
        break;
      case 'railway':
      case 'station':
        icon = Icons.train;
        break;
      case 'aerodrome':
        icon = Icons.flight;
        break;
      default:
        icon = Icons.place;
    }

    return InkWell(
      onTap: () => _selectPlace(place),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    place.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.north_west, color: AppColors.textHint, size: 16),
          ],
        ),
      ),
    );
  }

  // ──────────── Default content (recent + clear) ────────────

  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.recentSearches,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHint,
                      letterSpacing: 1.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await PlaceSearchService.instance.clearRecentSearches();
                      setState(() => _recentSearches = []);
                    },
                    child: Text(
                      'Clear all',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ..._recentSearches.map((place) {
              return InkWell(
                onTap: () => _selectPlace(place),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: AppColors.textHint, size: 20),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              place.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.north_west,
                          color: AppColors.textHint, size: 16),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Container(height: 8, color: AppColors.backgroundLight),
          ],

          // Tip when no recent searches
          if (_recentSearches.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search, size: 48, color: AppColors.textHint.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text(
                      'Search for any place, address\nor landmark',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ──────────── Current location tile ────────────

  Widget _buildCurrentLocationTile() {
    return InkWell(
      onTap: _useCurrentLocation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.my_location,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.currentLocation,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _currentLocationText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
