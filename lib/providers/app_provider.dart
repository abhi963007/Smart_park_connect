import 'package:flutter/material.dart';
import '../models/parking_spot.dart';
import '../models/booking.dart';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';
import '../services/local_storage_service.dart';

/// Main application state provider
/// Manages theme, user data, parking spots, bookings, and navigation
class AppProvider extends ChangeNotifier {
  // ---------- THEME ----------
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // ---------- AUTH STATE ----------
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _isOnboardingComplete = false;
  bool get isOnboardingComplete => _isOnboardingComplete;

  UserModel? _loggedInUser;

  void completeOnboarding() {
    _isOnboardingComplete = true;
    LocalStorageService.completeOnboarding();
    notifyListeners();
  }

  /// Initialize app state from local storage on startup
  Future<void> initFromStorage() async {
    _isOnboardingComplete = await LocalStorageService.isOnboardingComplete();
    _isLoggedIn = await LocalStorageService.isLoggedIn();
    if (_isLoggedIn) {
      _loggedInUser = await LocalStorageService.getCurrentUser();
    }
    // Seed default admin account
    await LocalStorageService.seedDefaultAdmin();
    notifyListeners();
  }

  /// Register a new user. Returns error string or null on success.
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final user = UserModel(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      password: password,
      role: role,
      isVerifiedOwner: role == UserRole.owner,
    );
    final error = await LocalStorageService.registerUser(user);
    if (error != null) return error;

    // Auto-login after registration
    _loggedInUser = user;
    _isLoggedIn = true;
    await LocalStorageService.saveSession(user);
    notifyListeners();
    return null;
  }

  /// Login with email and password. Returns error string or null on success.
  Future<String?> loginWithEmail(String email, String password) async {
    final user = await LocalStorageService.loginUser(email, password);
    if (user == null) return 'Invalid email or password.';

    _loggedInUser = user;
    _isLoggedIn = true;
    await LocalStorageService.saveSession(user);
    notifyListeners();
    return null;
  }

  void logout() {
    _isLoggedIn = false;
    _loggedInUser = null;
    LocalStorageService.clearSession();
    notifyListeners();
  }

  // ---------- USER ----------
  UserModel get currentUser =>
      _loggedInUser ?? MockDataService.currentUser;

  // ---------- PARKING SPOTS ----------
  List<ParkingSpot> get parkingSpots => MockDataService.parkingSpots;

  String _selectedFilter = 'All';
  String get selectedFilter => _selectedFilter;

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  List<ParkingSpot> get filteredSpots {
    if (_selectedFilter == 'All') return parkingSpots;
    if (_selectedFilter == 'Under \u20B950') {
      return parkingSpots.where((s) => s.pricePerHour <= 50).toList();
    }
    if (_selectedFilter == '\u2605 4.5+') {
      return parkingSpots.where((s) => s.rating >= 4.5).toList();
    }
    if (_selectedFilter == 'Covered') {
      return parkingSpots.where((s) => s.type == 'covered').toList();
    }
    return parkingSpots
        .where((s) => s.amenities.any(
            (a) => a.toUpperCase().contains(_selectedFilter.toUpperCase())))
        .toList();
  }

  // ---------- FAVORITES ----------
  final Set<String> _favoriteIds = {};
  Set<String> get favoriteIds => _favoriteIds;

  bool isFavorite(String id) => _favoriteIds.contains(id);

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }

  // ---------- BOOKINGS ----------
  final List<Booking> _userBookings = [];

  List<Booking> get bookings => [..._userBookings, ...MockDataService.sampleBookings];

  /// Add a new booking after successful payment
  void addBooking(Booking booking) {
    _userBookings.insert(0, booking);
    notifyListeners();
  }

  // ---------- BOOKING FLOW STATE ----------
  ParkingSpot? _selectedSpot;
  ParkingSpot? get selectedSpot => _selectedSpot;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay get startTime => _startTime;

  TimeOfDay _endTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay get endTime => _endTime;

  void selectSpot(ParkingSpot spot) {
    _selectedSpot = spot;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    _startTime = time;
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    _endTime = time;
    notifyListeners();
  }

  /// Calculate total duration in hours
  double get totalDurationHours {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    return (endMinutes - startMinutes) / 60.0;
  }

  /// Formatted duration string
  String get durationFormatted {
    final hours = totalDurationHours.floor();
    final mins = ((totalDurationHours - hours) * 60).round();
    if (mins == 0) return '$hours hours 00 mins';
    return '$hours hours ${mins.toString().padLeft(2, '0')} mins';
  }

  /// Estimated price based on selected spot and duration
  double get estimatedPrice {
    if (_selectedSpot == null) return 0;
    return _selectedSpot!.pricePerHour * totalDurationHours;
  }

  // ---------- BOTTOM NAV ----------
  int _currentNavIndex = 0;
  int get currentNavIndex => _currentNavIndex;

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  // ---------- SEARCH ----------
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<ParkingSpot> get searchResults {
    if (_searchQuery.isEmpty) return parkingSpots;
    return parkingSpots
        .where((s) =>
            s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.address.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }
}
