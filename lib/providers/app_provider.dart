import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parking_spot.dart';
import '../models/booking.dart';
import '../models/user_model.dart';
import '../models/chat_message.dart';
import '../services/local_storage_service.dart';

/// Main application state provider
/// Manages theme, user data, parking spots, bookings, and navigation
/// All data is persisted locally via SharedPreferences
class AppProvider extends ChangeNotifier {
  // ---------- THEME ----------
  final ThemeMode _themeMode = ThemeMode.light;
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
    if (_isLoggedIn) {
      _conversations =
          await LocalStorageService.getConversations(currentUser.id);
    }
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
      isVerifiedOwner: false, // Always false until admin approval
      approvalStatus: role == UserRole.owner
          ? ApprovalStatus.pending // Owners need admin approval
          : ApprovalStatus.approved, // Users and admins are auto-approved
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

  /// Approved spots only
  List<ParkingSpot> get approvedParkingSpots =>
      _parkingSpots.where((s) => s.status == 'approved').toList();

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
  Future<String?> addParkingSpot(ParkingSpot spot) async {
    // Check if current user is an approved owner
    if (!currentUser.canPerformOwnerActions) {
      if (currentUser.isPendingApproval) {
        return 'Your owner registration is pending admin approval. Please wait for approval before adding parking spots.';
      } else if (currentUser.isRejected) {
        return 'Your owner registration was rejected. Please contact support.';
      } else {
        return 'Only approved parking owners can add parking spots.';
      }
    }

    _parkingSpots.add(spot);
    await LocalStorageService.saveParkingSpots(_parkingSpots);
    notifyListeners();
    return null; // Success
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
          .where(
              (b) => b.ownerId == currentUser.id || b.userId == currentUser.id)
          .toList();
    }
    return _allBookings.where((b) => b.userId == currentUser.id).toList();
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
  int get activeBookingsCount => _allBookings
      .where((b) => b.status == 'confirmed' || b.status == 'active')
      .length;
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

  // ---------- USER MANAGEMENT (ADMIN) ----------
  /// Update user information (admin only)
  Future<String?> adminUpdateUser(
    String userId, {
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    ApprovalStatus? approvalStatus,
  }) async {
    try {
      final userIndex = _allUsers.indexWhere((u) => u.id == userId);
      if (userIndex == -1) return 'User not found';

      final currentUser = _allUsers[userIndex];
      final updatedUser = currentUser.copyWith(
        name: name,
        email: email,
        phone: phone,
        role: role,
        approvalStatus: approvalStatus,
      );

      // Use existing updateUser method from LocalStorageService
      await LocalStorageService.updateUser(updatedUser);

      // Reload all users to get updated data
      _allUsers = await LocalStorageService.getAllUsers();

      // Update logged in user if it's the same user
      if (_loggedInUser?.id == userId) {
        _loggedInUser = updatedUser;
      }

      notifyListeners();
      return null; // Success
    } catch (e) {
      return 'Failed to update user: $e';
    }
  }

  /// Delete user (admin only)
  Future<String?> deleteUser(String userId) async {
    try {
      // Prevent deleting the current logged in user
      if (_loggedInUser?.id == userId) {
        return 'Cannot delete currently logged in user';
      }

      final userIndex = _allUsers.indexWhere((u) => u.id == userId);
      if (userIndex == -1) return 'User not found';

      final userToDelete = _allUsers[userIndex];

      // If deleting an owner, also remove their parking spots
      if (userToDelete.role == UserRole.owner) {
        _parkingSpots.removeWhere((spot) => spot.ownerId == userId);
        await LocalStorageService.saveParkingSpots(_parkingSpots);
      }

      // Remove user from bookings as well
      _allBookings.removeWhere((booking) => booking.userId == userId);
      await LocalStorageService.saveBookings(_allBookings);

      // Remove the user - we'll need to manually update the users list
      _allUsers.removeAt(userIndex);
      final prefs = await SharedPreferences.getInstance();
      final usersJson = _allUsers.map((u) => u.toJsonString()).toList();
      await prefs.setStringList('users', usersJson);

      notifyListeners();
      return null; // Success
    } catch (e) {
      return 'Failed to delete user: $e';
    }
  }

  /// Get user by ID
  UserModel? getUserById(String userId) {
    try {
      return _allUsers.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  // ---------- MESSAGING ----------
  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;

  /// Load conversations for the current user
  Future<void> loadConversations() async {
    _conversations = await LocalStorageService.getConversations(currentUser.id);
    notifyListeners();
  }

  /// Get messages between current user and another user
  Future<List<ChatMessage>> getMessages(String otherUserId) async {
    return await LocalStorageService.getMessages(currentUser.id, otherUserId);
  }

  /// Send a message to another user
  Future<void> sendMessage({
    required String receiverId,
    required String receiverName,
    required String message,
  }) async {
    final msg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUser.id,
      senderName: currentUser.name,
      receiverId: receiverId,
      receiverName: receiverName,
      message: message,
      timestamp: DateTime.now(),
    );
    await LocalStorageService.saveMessage(msg);

    // Create or update conversation
    final convoId = _generateConvoId(currentUser.id, receiverId);
    final existingConvos = await LocalStorageService.getAllConversations();
    final existingIdx = existingConvos.indexWhere((c) => c.id == convoId);

    final convo = Conversation(
      id: convoId,
      user1Id: currentUser.id,
      user1Name: currentUser.name,
      user2Id: receiverId,
      user2Name: receiverName,
      lastMessage: message,
      lastMessageTime: DateTime.now(),
      unreadCount:
          existingIdx >= 0 ? existingConvos[existingIdx].unreadCount + 1 : 1,
    );
    await LocalStorageService.saveConversation(convo);
    await loadConversations();
  }

  /// Mark messages as read
  Future<void> markAsRead(String otherUserId) async {
    await LocalStorageService.markMessagesAsRead(
        currentUser.id, otherUserId, currentUser.id);
    // Reset unread count in conversation
    final convoId = _generateConvoId(currentUser.id, otherUserId);
    final allConvos = await LocalStorageService.getAllConversations();
    final idx = allConvos.indexWhere((c) => c.id == convoId);
    if (idx >= 0) {
      final updated = allConvos[idx].copyWith(unreadCount: 0);
      await LocalStorageService.saveConversation(updated);
    }
    await loadConversations();
  }

  /// Get or create a conversation ID between two users
  String _generateConvoId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return 'convo_${sorted[0]}_${sorted[1]}';
  }

  /// Get total unread message count for current user
  int get totalUnreadMessages {
    int count = 0;
    for (final c in _conversations) {
      if (c.user2Id == currentUser.id) {
        count += c.unreadCount;
      }
    }
    return count;
  }
}
