import 'package:flutter/material.dart';
import '../models/parking_spot.dart';
import '../models/booking.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';

/// Main application state provider
/// Manages theme, user data, parking spots, bookings, and navigation
/// All data is persisted locally via SharedPreferences
class AppProvider extends ChangeNotifier {
  // ---------- THEME ----------
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

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
    // Seed initial data (admin, owner, parking spots)
    await LocalStorageService.seedInitialData();
    // Load all persisted data
    _parkingSpots = await LocalStorageService.getAllParkingSpots();
    _allBookings = await LocalStorageService.getAllBookings();
    _favoriteIds = await LocalStorageService.getFavorites();
    _allUsers = await LocalStorageService.getAllUsers();
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

    _loggedInUser = user;
    _isLoggedIn = true;
    await LocalStorageService.saveSession(user);
    _allUsers = await LocalStorageService.getAllUsers();
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
    // Reload data for this user
    _allBookings = await LocalStorageService.getAllBookings();
    _favoriteIds = await LocalStorageService.getFavorites();
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
      _loggedInUser ??
      const UserModel(id: 'guest', name: 'Guest', email: 'guest@app.com');

  /// Update the current user's profile
  Future<void> updateUser(UserModel updatedUser) async {
    await LocalStorageService.updateUser(updatedUser);
    _loggedInUser = updatedUser;
    _allUsers = await LocalStorageService.getAllUsers();
    notifyListeners();
  }

  /// Reset password for user with given email
  Future<String?> resetPassword(String email, String newPassword) async {
    return await LocalStorageService.resetPassword(email, newPassword);
  }

  // ---------- ALL USERS (for admin) ----------
  List<UserModel> _allUsers = [];
  List<UserModel> get allUsers => _allUsers;

  Future<void> refreshUsers() async {
    _allUsers = await LocalStorageService.getAllUsers();
    notifyListeners();
  }

  // ---------- PARKING SPOTS ----------
  List<ParkingSpot> _parkingSpots = [];
  List<ParkingSpot> get parkingSpots =>
      _parkingSpots.where((s) => s.status == 'approved').toList();

  /// All spots including pending (for admin/owner)
  List<ParkingSpot> get allParkingSpots => _parkingSpots;

  /// Spots owned by current user
  List<ParkingSpot> get myParkingSpots =>
      _parkingSpots.where((s) => s.ownerId == currentUser.id).toList();

  /// Pending spots (for admin approval)
  List<ParkingSpot> get pendingParkingSpots =>
      _parkingSpots.where((s) => s.status == 'pending').toList();

  String _selectedFilter = 'All';
  String get selectedFilter => _selectedFilter;

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  List<ParkingSpot> get filteredSpots {
    final approved = parkingSpots;
    if (_selectedFilter == 'All') return approved;
    if (_selectedFilter == 'Under \u20B950') {
      return approved.where((s) => s.pricePerHour <= 50).toList();
    }
    if (_selectedFilter == '\u2605 4.5+') {
      return approved.where((s) => s.rating >= 4.5).toList();
    }
    if (_selectedFilter == 'Covered') {
      return approved.where((s) => s.type == 'covered').toList();
    }
    return approved
        .where((s) => s.amenities.any(
            (a) => a.toUpperCase().contains(_selectedFilter.toUpperCase())))
        .toList();
  }

  /// Add a new parking spot (owner action)
  Future<void> addParkingSpot(ParkingSpot spot) async {
    _parkingSpots.add(spot);
    await LocalStorageService.saveParkingSpots(_parkingSpots);
    notifyListeners();
  }

  /// Approve a parking spot (admin action)
  Future<void> approveParkingSpot(String id) async {
    final idx = _parkingSpots.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _parkingSpots[idx] = _parkingSpots[idx].copyWith(status: 'approved');
      await LocalStorageService.saveParkingSpots(_parkingSpots);
      notifyListeners();
    }
  }

  /// Reject a parking spot (admin action)
  Future<void> rejectParkingSpot(String id) async {
    final idx = _parkingSpots.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _parkingSpots[idx] = _parkingSpots[idx].copyWith(status: 'rejected');
      await LocalStorageService.saveParkingSpots(_parkingSpots);
      notifyListeners();
    }
  }

  /// Delete a parking spot
  Future<void> deleteParkingSpot(String id) async {
    _parkingSpots.removeWhere((s) => s.id == id);
    await LocalStorageService.saveParkingSpots(_parkingSpots);
    notifyListeners();
  }

  // ---------- FAVORITES ----------
  Set<String> _favoriteIds = {};
  Set<String> get favoriteIds => _favoriteIds;

  bool isFavorite(String id) => _favoriteIds.contains(id);

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    LocalStorageService.saveFavorites(_favoriteIds);
    notifyListeners();
  }

  // ---------- BOOKINGS ----------
  List<Booking> _allBookings = [];

  /// Bookings for current user (driver sees their bookings)
  List<Booking> get bookings {
    if (currentUser.role == UserRole.admin) return _allBookings;
    if (currentUser.role == UserRole.owner) {
      return _allBookings
          .where((b) =>
              b.ownerId == currentUser.id || b.userId == currentUser.id)
          .toList();
    }
    return _allBookings
        .where((b) => b.userId == currentUser.id)
        .toList();
  }

  /// All bookings (for admin)
  List<Booking> get allBookings => _allBookings;

  /// Bookings for owner's spots
  List<Booking> get ownerBookings =>
      _allBookings.where((b) => b.ownerId == currentUser.id).toList();

  /// Add a new booking after successful payment
  Future<void> addBooking(Booking booking) async {
    _allBookings.insert(0, booking);
    await LocalStorageService.saveBookings(_allBookings);
    notifyListeners();
  }

  /// Update booking status
  Future<void> updateBookingStatus(String id, String status) async {
    final idx = _allBookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _allBookings[idx] = _allBookings[idx].copyWith(status: status);
      await LocalStorageService.saveBookings(_allBookings);
      notifyListeners();
    }
  }

  // ---------- OWNER STATS ----------
  double get ownerTotalEarnings {
    return ownerBookings
        .where((b) => b.status == 'completed')
        .fold(0.0, (sum, b) => sum + b.totalPrice);
  }

  int get ownerActiveBookings {
    return ownerBookings
        .where((b) => b.status == 'confirmed' || b.status == 'active')
        .length;
  }

  // ---------- ADMIN STATS ----------
  int get totalUsersCount => _allUsers.length;
  int get totalSpotsCount => _parkingSpots.length;
  int get activeBookingsCount =>
      _allBookings.where((b) => b.status == 'confirmed' || b.status == 'active').length;
  double get totalRevenue =>
      _allBookings.fold(0.0, (sum, b) => sum + b.totalPrice);

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
