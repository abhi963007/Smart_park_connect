import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import '../../services/place_search_service.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/parking_spot.dart';
import '../../models/booking.dart';
import '../../widgets/map_pin.dart';

/// Owner dashboard screen with stats, manage parkings, earnings overview
class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final mySpots = provider.myParkingSpots;
    final myBookings = provider.ownerBookings;
    final earnings = provider.ownerTotalEarnings;
    final activeCount = provider.ownerActiveBookings;
    final avgRating = mySpots.isEmpty
        ? 0.0
        : mySpots.fold(0.0, (sum, s) => sum + s.rating) / mySpots.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Owner Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Earnings',
                    '\u20B9${earnings.toStringAsFixed(0)}',
                    Icons.account_balance_wallet,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Active Bookings',
                    '$activeCount',
                    Icons.calendar_today,
                    AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Spaces',
                    '${mySpots.length}',
                    Icons.local_parking,
                    AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Avg Rating',
                    avgRating.toStringAsFixed(1),
                    Icons.star,
                    AppColors.starYellow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Quick Actions
            Text(
              'QUICK ACTIONS',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textHint,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              Icons.add_circle_outline,
              'Add New Parking Space',
              'List a new parking spot for rent',
              AppColors.primary,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _AddParkingScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              Icons.manage_history,
              'Manage Bookings',
              'View and manage incoming bookings',
              AppColors.accent,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const _ManageBookingsScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              Icons.bar_chart,
              'Earnings Overview',
              'View detailed earnings and analytics',
              AppColors.success,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _EarningsScreen()),
              ),
            ),
            const SizedBox(height: 28),

            // Recent Bookings
            Text(
              'RECENT BOOKINGS',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textHint,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            if (myBookings.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No bookings yet',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              )
            else
              ...myBookings.take(5).map((b) {
                final dateFormat = DateFormat('dd MMM, hh:mm a');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildRecentBooking(
                    b.userName.isEmpty ? 'User' : b.userName,
                    b.parkingName,
                    dateFormat.format(b.startTime),
                    '\u20B9${b.totalPrice.toStringAsFixed(0)}',
                    b.status,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBooking(String userName, String spotName, String dateTime,
      String amount, String status) {
    Color statusColor;
    switch (status) {
      case 'confirmed':
        statusColor = AppColors.primary;
        break;
      case 'active':
        statusColor = AppColors.success;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              userName[0],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  dateTime,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Add Parking Space form screen - functional
class _AddParkingScreen extends StatefulWidget {
  const _AddParkingScreen();

  @override
  State<_AddParkingScreen> createState() => _AddParkingScreenState();
}

class _AddParkingScreenState extends State<_AddParkingScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descController = TextEditingController();
  final _latController = TextEditingController(text: '12.9716');
  final _lngController = TextEditingController(text: '77.5946');
  String _selectedType = 'covered';
  final Set<String> _selectedAmenities = {'CCTV'};
  File? _pickedImage;
  final ImagePicker _imagePicker = ImagePicker();

  final MapController _mapController = MapController();
  LatLng _pickedLocation = const LatLng(12.9716, 77.5946);

  // Search state
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  List<PlaceResult> _searchResults = [];
  List<PlaceResult> _recentSearches = [];
  bool _isSearching = false;
  bool _showSearchDropdown = false;
  bool _isReverseGeocoding = false;
  Timer? _debounce;

  final List<Map<String, dynamic>> _amenityOptions = [
    {'name': 'CCTV', 'icon': Icons.videocam_outlined},
    {'name': 'EV Charging', 'icon': Icons.ev_station_outlined},
    {'name': '24/7 Access', 'icon': Icons.access_time_outlined},
    {'name': 'Valet', 'icon': Icons.person_outline},
    {'name': 'Covered', 'icon': Icons.garage_outlined},
    {'name': 'Security', 'icon': Icons.security_outlined},
    {'name': 'Water', 'icon': Icons.water_drop_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _latController.addListener(_onLatLngChanged);
    _lngController.addListener(_onLatLngChanged);
    // Initialize controllers with default lat/lng
    _latController.text = _pickedLocation.latitude.toStringAsFixed(6);
    _lngController.text = _pickedLocation.longitude.toStringAsFixed(6);

    // Load recent searches
    _loadRecentSearches();

    // Listen to search focus changes
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  Future<void> _loadRecentSearches() async {
    final recent = await PlaceSearchService.instance.getRecentSearches();
    if (mounted) {
      setState(() => _recentSearches = recent);
    }
  }

  void _onSearchFocusChanged() {
    if (_searchFocusNode.hasFocus) {
      setState(() => _showSearchDropdown = true);
    }
  }

  void _onLatLngChanged() {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    if (lat != null && lng != null) {
      final newPos = LatLng(lat, lng);
      // Only move if significantly different to avoid feedback loops
      if ((newPos.latitude - _pickedLocation.latitude).abs() > 0.00001 ||
          (newPos.longitude - _pickedLocation.longitude).abs() > 0.00001) {
        setState(() {
          _pickedLocation = newPos;
        });
        _mapController.move(newPos, _mapController.camera.zoom);
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location services are disabled. Please enable GPS.',
                style: GoogleFonts.poppins()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OPEN SETTINGS',
              textColor: Colors.white,
              onPressed: () => Geolocator.openLocationSettings(),
            ),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location permission denied.',
                  style: GoogleFonts.poppins()),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Location permission permanently denied. Please enable in app settings.',
                style: GoogleFonts.poppins()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OPEN SETTINGS',
              textColor: Colors.white,
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ),
        );
        return;
      }

      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text('Fetching your location...', style: GoogleFonts.poppins()),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 10),
        ),
      );

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      setState(() {
        _pickedLocation = latLng;
        _latController.text = latLng.latitude.toStringAsFixed(6);
        _lngController.text = latLng.longitude.toStringAsFixed(6);
      });

      _mapController.move(latLng, 15);

      // Reverse geocode to get address
      _reverseGeocodeLocation(latLng);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Location fetched successfully!',
                  style: GoogleFonts.poppins()),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to get location: $e', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isSearching = true);
      try {
        final results = await PlaceSearchService.instance
            .search(query, nearLatLng: _pickedLocation);
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } catch (_) {
        setState(() => _isSearching = false);
      }
    });
  }

  void _selectSearchResult(PlaceResult place) {
    final latLng = place.latLng;
    setState(() {
      _pickedLocation = latLng;
      _latController.text = latLng.latitude.toStringAsFixed(6);
      _lngController.text = latLng.longitude.toStringAsFixed(6);
      _searchResults = [];
      _showSearchDropdown = false;
      _searchController.text = place.title;
      // Auto-fill address field with the selected place
      if (_addressController.text.isEmpty ||
          _addressController.text == place.title) {
        _addressController.text = place.displayName;
      }
      FocusScope.of(context).unfocus();
    });
    _mapController.move(latLng, 16);
    // Save to recent searches
    PlaceSearchService.instance.addRecentSearch(place);
    _loadRecentSearches();
  }

  Future<void> _reverseGeocodeLocation(LatLng point) async {
    setState(() => _isReverseGeocoding = true);
    try {
      final place = await PlaceSearchService.instance.reverseGeocode(point);
      if (place != null && mounted) {
        setState(() {
          _searchController.text = place.title;
          // Auto-fill address if empty
          if (_addressController.text.isEmpty) {
            _addressController.text = place.displayName;
          }
        });
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isReverseGeocoding = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    _searchController.dispose();
    _latController.removeListener(_onLatLngChanged);
    _lngController.removeListener(_onLatLngChanged);
    _nameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _descController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to pick image: $e', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textHint.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Parking Photo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: Text('Take Photo',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                subtitle: Text('Use camera to capture',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.textSecondary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.photo_library_rounded,
                      color: AppColors.accent),
                ),
                title: Text('Choose from Gallery',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                subtitle: Text('Select from your photos',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.textSecondary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_pickedImage != null)
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delete_outline_rounded,
                        color: AppColors.error),
                  ),
                  title: Text('Remove Photo',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _pickedImage = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields',
              style: GoogleFonts.poppins()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final provider = context.read<AppProvider>();
    final user = provider.currentUser;
    final spot = ParkingSpot(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: user.id,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      rating: 0.0,
      reviewCount: 0,
      pricePerHour: double.tryParse(_priceController.text) ?? 0,
      distance: 0.0,
      walkTime: 0,
      amenities: _selectedAmenities.toList(),
      tags: [_selectedType.toUpperCase()],
      imageUrl: _pickedImage?.path ?? '',
      galleryImages: _pickedImage?.path != null ? [_pickedImage!.path] : [],
      ownerName: user.name,
      ownerAvatar: '',
      description: _descController.text.trim(),
      latitude: double.tryParse(_latController.text) ?? 12.9716,
      longitude: double.tryParse(_lngController.text) ?? 77.5946,
      type: _selectedType,
      status: 'pending',
      capacity: int.tryParse(_capacityController.text) ?? 10,
      createdAt: DateTime.now(),
    );

    provider.addParkingSpot(spot);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Parking space submitted for approval!',
            style: GoogleFonts.poppins()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Parking Space',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormField(
                'Space Name *', 'e.g. My Garage Parking', _nameController,
                icon: Icons.business_outlined),
            const SizedBox(height: 16),
            _buildFormField('Address *', 'Full address of parking space',
                _addressController,
                icon: Icons.location_on_outlined),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildFormField(
                        'Price/Hour *', '\u20B9', _priceController,
                        isNumber: true, icon: Icons.payments_outlined)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildFormField(
                        'Capacity', 'Spots', _capacityController,
                        isNumber: true, icon: Icons.directions_car_outlined)),
              ],
            ),
            const SizedBox(height: 16),
            _buildFormField('Description', 'Describe your parking space...',
                _descController,
                maxLines: 3, icon: Icons.description_outlined),
            const SizedBox(height: 20),

            // Parking Photo Section
            Text('Parking Photo',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('Add a photo of your parking space',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showImagePickerSheet,
              child: Container(
                width: double.infinity,
                height: _pickedImage != null ? 200 : 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _pickedImage != null
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.cardBorder,
                    width: _pickedImage != null ? 2 : 1,
                    style: _pickedImage != null
                        ? BorderStyle.solid
                        : BorderStyle.solid,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _pickedImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              _pickedImage!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Edit overlay
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.edit,
                                          color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text('Change',
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _pickedImage = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.error
                                          .withValues(alpha: 0.85),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add_a_photo_rounded,
                                color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(height: 10),
                          Text('Tap to add photo',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary)),
                          const SizedBox(height: 4),
                          Text('Camera or Gallery',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: AppColors.textHint)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Map Location Picker Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Location on Map',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                TextButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location, size: 16),
                  label: Text('My Location',
                      style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Premium Search Bar with Dropdown
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _searchFocusNode.hasFocus
                          ? AppColors.primary
                          : AppColors.cardBorder.withValues(alpha: 0.3),
                      width: _searchFocusNode.hasFocus ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _searchFocusNode.hasFocus
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.03),
                        blurRadius: _searchFocusNode.hasFocus ? 16 : 8,
                        spreadRadius: _searchFocusNode.hasFocus ? 1 : 0,
                        offset: Offset(0, _searchFocusNode.hasFocus ? 6 : 3),
                      ),
                      if (_searchFocusNode.hasFocus)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          blurRadius: 32,
                          spreadRadius: -4,
                          offset: const Offset(0, 8),
                        ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _onSearchChanged,
                    onTap: () => setState(() => _showSearchDropdown = true),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search for a place or area...',
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.textHint.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _isSearching
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              )
                            : Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withValues(alpha: 0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.search_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.textHint.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded,
                                    size: 14, color: AppColors.textSecondary),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults = [];
                                  _showSearchDropdown = false;
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                ),

                // Search Results Dropdown (below search bar)
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: (_showSearchDropdown &&
                          (_searchResults.isNotEmpty ||
                              _recentSearches.isNotEmpty ||
                              _isSearching))
                      ? Container(
                          constraints: const BoxConstraints(maxHeight: 220),
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: _buildSearchDropdownContent(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Map
            Stack(
              children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _pickedLocation,
                        initialZoom: 13,
                        onTap: (tapPosition, point) {
                          setState(() {
                            _pickedLocation = point;
                            _latController.text =
                                point.latitude.toStringAsFixed(6);
                            _lngController.text =
                                point.longitude.toStringAsFixed(6);
                            _showSearchDropdown = false;
                          });
                          // Reverse geocode to get address
                          _reverseGeocodeLocation(point);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.smartparkconnect.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _pickedLocation,
                              width: 44,
                              height: 44,
                              alignment: Alignment.bottomCenter,
                              child: const MapPin(size: 44),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Reverse geocoding indicator
                if (_isReverseGeocoding)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Getting address...',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Tap hint
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Tap on map to select location',
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildFormField(
                        'Latitude', '12.9716', _latController,
                        isNumber: true, icon: Icons.map_outlined)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildFormField(
                        'Longitude', '77.5946', _lngController,
                        isNumber: true, icon: Icons.map_outlined)),
              ],
            ),
            const SizedBox(height: 16),
            // Parking type
            Text('Parking Type',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['covered', 'open', 'underground'].map((type) {
                  final label = type[0].toUpperCase() + type.substring(1);
                  final isSelected = _selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.12),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.cardBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedType = type);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Amenities
            Text('Amenities',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _amenityOptions.map((amenity) {
                final name = amenity['name'] as String;
                final icon = amenity['icon'] as IconData;
                final isSelected = _selectedAmenities.contains(name);

                return FilterChip(
                  avatar: Icon(icon,
                      size: 16,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary),
                  label: Text(name),
                  selected: isSelected,
                  selectedColor: AppColors.primary.withValues(alpha: 0.12),
                  checkmarkColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color:
                          isSelected ? AppColors.primary : AppColors.cardBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAmenities.add(name);
                      } else {
                        _selectedAmenities.remove(name);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('Submit for Approval',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchDropdownContent() {
    // Show loading indicator
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      );
    }

    // Show search results if available
    if (_searchResults.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final place = _searchResults[index];
          return _buildPlaceListTile(
            place: place,
            icon: Icons.location_on_outlined,
            iconColor: AppColors.primary,
            onTap: () => _selectSearchResult(place),
          );
        },
      );
    }

    // Show recent searches if no search results and query is empty
    if (_recentSearches.isNotEmpty && _searchController.text.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.history, size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Text(
                  'Recent Searches',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHint,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    await PlaceSearchService.instance.clearRecentSearches();
                    _loadRecentSearches();
                  },
                  child: Text(
                    'Clear',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount:
                  _recentSearches.length > 5 ? 5 : _recentSearches.length,
              itemBuilder: (context, index) {
                final place = _recentSearches[index];
                return _buildPlaceListTile(
                  place: place,
                  icon: Icons.history,
                  iconColor: AppColors.textSecondary,
                  onTap: () => _selectSearchResult(place),
                );
              },
            ),
          ),
        ],
      );
    }

    // Empty state
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          'Type to search for places...',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textHint),
        ),
      ),
    );
  }

  Widget _buildPlaceListTile({
    required PlaceResult place,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      place.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.north_west, size: 14, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
      String label, String hint, TextEditingController controller,
      {int maxLines = 1, bool isNumber = false, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: icon != null
                ? Icon(icon,
                    color: AppColors.primary.withValues(alpha: 0.7), size: 20)
                : null,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.cardBorder)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.cardBorder)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

/// Manage Bookings screen for owners - dynamic
class _ManageBookingsScreen extends StatelessWidget {
  const _ManageBookingsScreen();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final myBookings = provider.ownerBookings;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Bookings',
          style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: myBookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today,
                      size: 64,
                      color: AppColors.textHint.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('No bookings yet',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Bookings for your parking\nspots will appear here.',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: AppColors.textHint),
                      textAlign: TextAlign.center),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: myBookings.length,
              itemBuilder: (context, index) {
                final b = myBookings[index];
                final dateFormat = DateFormat('dd MMM, hh:mm a');
                Color statusColor;
                switch (b.status) {
                  case 'confirmed':
                    statusColor = AppColors.primary;
                    break;
                  case 'active':
                    statusColor = AppColors.success;
                    break;
                  case 'completed':
                    statusColor = AppColors.textSecondary;
                    break;
                  default:
                    statusColor = AppColors.error;
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.cardBorder.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              (b.userName.isEmpty ? 'U' : b.userName[0]),
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.userName.isEmpty ? 'User' : b.userName,
                                    style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary)),
                                Text(b.parkingName,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(b.status.toUpperCase(),
                                style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                          '${dateFormat.format(b.startTime)} - ${DateFormat('hh:mm a').format(b.endTime)}',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: AppColors.textSecondary)),
                      Text('\u20B9${b.totalPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                      if (b.status == 'confirmed') ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => provider.updateBookingStatus(
                                    b.id, 'cancelled'),
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: const BorderSide(
                                        color: AppColors.error),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                child: Text('Cancel',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => provider.updateBookingStatus(
                                    b.id, 'completed'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    elevation: 0),
                                child: Text('Complete',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

/// Earnings overview screen for owners - dynamic
class _EarningsScreen extends StatelessWidget {
  const _EarningsScreen();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final myBookings = provider.ownerBookings;
    final totalEarnings = provider.ownerTotalEarnings;
    final completedBookings =
        myBookings.where((b) => b.status == 'completed').toList();

    // Group by month
    final Map<String, List<Booking>> monthlyMap = {};
    for (final b in completedBookings) {
      final key = DateFormat('MMMM yyyy').format(b.startTime);
      monthlyMap.putIfAbsent(key, () => []);
      monthlyMap[key]!.add(b);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Earnings Overview',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total earnings card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Earnings',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text('\u20B9${totalEarnings.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('${completedBookings.length} completed bookings',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Monthly breakdown
            Text('MONTHLY BREAKDOWN',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHint,
                    letterSpacing: 1.2)),
            const SizedBox(height: 12),
            if (monthlyMap.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('No earnings data yet',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: AppColors.textHint)),
                ),
              )
            else
              ...monthlyMap.entries.map((entry) {
                final monthTotal =
                    entry.value.fold(0.0, (sum, b) => sum + b.totalPrice);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.cardBorder.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.key,
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            Text('${entry.value.length} bookings',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Text('\u20B9${monthTotal.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success)),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
