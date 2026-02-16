import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/parking_spot.dart';
import '../models/booking.dart';
import '../models/chat_message.dart';

/// Local storage service for prototype authentication
/// Stores user accounts and session data on device using SharedPreferences
class LocalStorageService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _parkingSpotsKey = 'parking_spots';
  static const String _bookingsKey = 'bookings';
  static const String _favoritesKey = 'favorite_ids';
  static const String _dataSeededKey = 'data_seeded_v3';
  static const String _messagesKey = 'chat_messages';
  static const String _conversationsKey = 'conversations';

  // ---------- USER REGISTRATION ----------

  /// Register a new user locally. Returns error message or null on success.
  static Future<String?> registerUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getAllUsers();

    // Check if email already exists
    final exists = users.any(
      (u) => u.email.toLowerCase() == user.email.toLowerCase(),
    );
    if (exists) {
      return 'An account with this email already exists.';
    }

    users.add(user);
    final jsonList = users.map((u) => u.toJsonString()).toList();
    await prefs.setStringList(_usersKey, jsonList);
    return null;
  }

  /// Get all registered users from local storage
  static Future<List<UserModel>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_usersKey) ?? [];
    return jsonList.map((s) => UserModel.fromJsonString(s)).toList();
  }

  /// Update an existing user's profile data
  static Future<void> updateUser(UserModel updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getAllUsers();

    // Find and update the user
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;

      // Save updated users list
      final usersJson = users.map((u) => u.toJsonString()).toList();
      await prefs.setStringList(_usersKey, usersJson);

      // Update current user if it's the same user
      final currentUserId = prefs.getString(_currentUserKey);
      if (currentUserId == updatedUser.id) {
        await prefs.setString(_currentUserKey, updatedUser.toJsonString());
      }
    }
  }

  /// Reset user password by email
  static Future<String?> resetPassword(String email, String newPassword) async {
    final users = await getAllUsers();

    // Find user by email
    final userIndex =
        users.indexWhere((u) => u.email.toLowerCase() == email.toLowerCase());
    if (userIndex == -1) {
      return 'User not found';
    }

    // Update password
    final user = users[userIndex];
    final updatedUser = user.copyWith(password: newPassword);
    users[userIndex] = updatedUser;

    // Save updated users list
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users.map((u) => u.toJsonString()).toList();
    await prefs.setStringList(_usersKey, usersJson);

    return null; // Success
  }

  /// Get all pending owner registrations for admin approval
  static Future<List<UserModel>> getPendingOwnerApprovals() async {
    final users = await getAllUsers();
    return users
        .where((user) =>
            user.role == UserRole.owner &&
            user.approvalStatus == ApprovalStatus.pending)
        .toList();
  }

  /// Approve an owner registration (admin action)
  static Future<String?> approveOwner(String userId) async {
    final users = await getAllUsers();
    final userIndex = users.indexWhere((u) => u.id == userId);

    if (userIndex == -1) {
      return 'User not found';
    }

    final user = users[userIndex];
    if (user.role != UserRole.owner) {
      return 'User is not an owner';
    }

    // Update user status to approved
    final updatedUser = user.copyWith(
      approvalStatus: ApprovalStatus.approved,
      isVerifiedOwner: true,
    );
    users[userIndex] = updatedUser;

    // Save updated users list
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users.map((u) => u.toJsonString()).toList();
    await prefs.setStringList(_usersKey, usersJson);

    return null; // Success
  }

  /// Reject an owner registration (admin action)
  static Future<String?> rejectOwner(String userId) async {
    final users = await getAllUsers();
    final userIndex = users.indexWhere((u) => u.id == userId);

    if (userIndex == -1) {
      return 'User not found';
    }

    final user = users[userIndex];
    if (user.role != UserRole.owner) {
      return 'User is not an owner';
    }

    // Update user status to rejected
    final updatedUser = user.copyWith(
      approvalStatus: ApprovalStatus.rejected,
      isVerifiedOwner: false,
    );
    users[userIndex] = updatedUser;

    // Save updated users list
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users.map((u) => u.toJsonString()).toList();
    await prefs.setStringList(_usersKey, usersJson);

    return null; // Success
  }

  // ---------- LOGIN / LOGOUT ----------

  /// Authenticate user with email and password. Returns UserModel or null.
  static Future<UserModel?> loginUser(String email, String password) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase() &&
            u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  /// Save current logged-in user session
  static Future<void> saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, user.toJsonString());
    await prefs.setBool(_isLoggedInKey, true);
  }

  /// Get current logged-in user from session
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_currentUserKey);
    if (jsonStr == null) return null;
    return UserModel.fromJsonString(jsonStr);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Clear session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // ---------- ONBOARDING ----------

  /// Check if onboarding has been completed
  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  /// Mark onboarding as complete
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
  }

  // ---------- PARKING SPOTS ----------

  static Future<List<ParkingSpot>> getAllParkingSpots() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_parkingSpotsKey) ?? [];
    return jsonList.map((s) => ParkingSpot.fromJsonString(s)).toList();
  }

  static Future<void> saveParkingSpots(List<ParkingSpot> spots) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = spots.map((s) => s.toJsonString()).toList();
    await prefs.setStringList(_parkingSpotsKey, jsonList);
  }

  static Future<void> addParkingSpot(ParkingSpot spot) async {
    final spots = await getAllParkingSpots();
    spots.add(spot);
    await saveParkingSpots(spots);
  }

  static Future<void> updateParkingSpot(ParkingSpot updated) async {
    final spots = await getAllParkingSpots();
    final idx = spots.indexWhere((s) => s.id == updated.id);
    if (idx != -1) {
      spots[idx] = updated;
      await saveParkingSpots(spots);
    }
  }

  static Future<void> deleteParkingSpot(String id) async {
    final spots = await getAllParkingSpots();
    spots.removeWhere((s) => s.id == id);
    await saveParkingSpots(spots);
  }

  // ---------- BOOKINGS ----------

  static Future<List<Booking>> getAllBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_bookingsKey) ?? [];
    return jsonList.map((s) => Booking.fromJsonString(s)).toList();
  }

  static Future<void> saveBookings(List<Booking> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = bookings.map((b) => b.toJsonString()).toList();
    await prefs.setStringList(_bookingsKey, jsonList);
  }

  static Future<void> addBooking(Booking booking) async {
    final bookings = await getAllBookings();
    bookings.insert(0, booking);
    await saveBookings(bookings);
  }

  static Future<void> updateBooking(Booking updated) async {
    final bookings = await getAllBookings();
    final idx = bookings.indexWhere((b) => b.id == updated.id);
    if (idx != -1) {
      bookings[idx] = updated;
      await saveBookings(bookings);
    }
  }

  // ---------- FAVORITES ----------

  static Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favoritesKey) ?? [];
    return list.toSet();
  }

  static Future<void> saveFavorites(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, ids.toList());
  }

  // ---------- SEED DATA ----------

  static Future<void> seedDefaultAdmin() async {
    final users = await getAllUsers();
    final hasAdmin = users.any((u) => u.role == UserRole.admin);
    if (!hasAdmin) {
      await registerUser(const UserModel(
        id: 'admin_001',
        name: 'Admin',
        email: 'admin@smartpark.com',
        password: 'admin123',
        role: UserRole.admin,
        isVerifiedOwner: true,
      ));
    }
  }

  /// Seed initial data (admin + sample owner accounts only)
  /// No hardcoded parking spots – only owner-added spots will appear
  static Future<void> seedInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeeded = prefs.getBool(_dataSeededKey) ?? false;
    if (alreadySeeded) return;

    // Clear old hardcoded parking spots from previous seed versions
    await prefs.remove(_parkingSpotsKey);

    // Seed admin
    await seedDefaultAdmin();

    // Seed sample owner
    final users = await getAllUsers();
    final hasOwner = users.any((u) => u.role == UserRole.owner);
    if (!hasOwner) {
      await registerUser(const UserModel(
        id: 'owner_001',
        name: 'Arjun Sharma',
        email: 'arjun@smartpark.com',
        password: 'owner123',
        role: UserRole.owner,
        isVerifiedOwner: true,
      ));
    }

    await prefs.setBool(_dataSeededKey, true);
  }

  // ---------- MESSAGING ----------

  /// Get all messages for a conversation between two users
  static Future<List<ChatMessage>> getMessages(
      String visitorId, String ownerId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_messagesKey) ?? [];
    final allMessages =
        jsonList.map((s) => ChatMessage.fromJsonString(s)).toList();
    return allMessages
        .where((m) =>
            (m.senderId == visitorId && m.receiverId == ownerId) ||
            (m.senderId == ownerId && m.receiverId == visitorId))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Save a new chat message
  static Future<void> saveMessage(ChatMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_messagesKey) ?? [];
    jsonList.add(message.toJsonString());
    await prefs.setStringList(_messagesKey, jsonList);
  }

  /// Get all conversations for a user
  static Future<List<Conversation>> getConversations(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_conversationsKey) ?? [];
    final allConvos =
        jsonList.map((s) => Conversation.fromJsonString(s)).toList();
    return allConvos
        .where((c) => c.user1Id == userId || c.user2Id == userId)
        .toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  /// Get all conversations (all users)
  static Future<List<Conversation>> getAllConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_conversationsKey) ?? [];
    return jsonList.map((s) => Conversation.fromJsonString(s)).toList();
  }

  /// Create or update a conversation
  static Future<void> saveConversation(Conversation conversation) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_conversationsKey) ?? [];
    final allConvos =
        jsonList.map((s) => Conversation.fromJsonString(s)).toList();
    final idx = allConvos.indexWhere((c) => c.id == conversation.id);
    if (idx >= 0) {
      allConvos[idx] = conversation;
    } else {
      allConvos.add(conversation);
    }
    await prefs.setStringList(
        _conversationsKey, allConvos.map((c) => c.toJsonString()).toList());
  }

  /// Mark all messages in a conversation as read for a user
  static Future<void> markMessagesAsRead(
      String visitorId, String ownerId, String readerId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_messagesKey) ?? [];
    final allMessages =
        jsonList.map((s) => ChatMessage.fromJsonString(s)).toList();
    for (int i = 0; i < allMessages.length; i++) {
      final m = allMessages[i];
      if (m.receiverId == readerId &&
          ((m.senderId == visitorId && m.receiverId == ownerId) ||
              (m.senderId == ownerId && m.receiverId == visitorId)) &&
          !m.isRead) {
        allMessages[i] = m.copyWith(isRead: true);
      }
    }
    await prefs.setStringList(
        _messagesKey, allMessages.map((m) => m.toJsonString()).toList());
  }
}
