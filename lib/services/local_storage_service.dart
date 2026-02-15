import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/parking_spot.dart';
import '../models/booking.dart';

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
  static const String _dataSeededKey = 'data_seeded_v2';

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
    final idx = users.indexWhere((u) => u.id == updatedUser.id);
    if (idx != -1) {
      users[idx] = updatedUser;
    }
    final jsonList = users.map((u) => u.toJsonString()).toList();
    await prefs.setStringList(_usersKey, jsonList);
    // Also update session if this is the current user
    await saveSession(updatedUser);
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

  /// Seed initial parking spots if not already seeded
  static Future<void> seedInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeeded = prefs.getBool(_dataSeededKey) ?? false;
    if (alreadySeeded) return;

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

    // Seed parking spots
    final existingSpots = await getAllParkingSpots();
    if (existingSpots.isEmpty) {
      final now = DateTime.now();
      final spots = [
        ParkingSpot(
          id: 'p1',
          ownerId: 'owner_001',
          name: 'Urban Parking Station',
          address: '452 Premium Enclave, Silicon Heights, Sector 62, Bangalore',
          rating: 4.8,
          reviewCount: 120,
          pricePerHour: 50,
          distance: 0.3,
          walkTime: 5,
          amenities: ['COVERED', 'CCTV', 'EV CHARGE', '24/7'],
          tags: ['COVERED', 'CCTV'],
          imageUrl: 'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=400',
          galleryImages: [
            'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=800',
            'https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?w=800',
          ],
          ownerName: 'Arjun Sharma',
          ownerAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
          description: 'Secure and spacious parking spot located in the heart of Silicon Heights.',
          latitude: 12.9716,
          longitude: 77.5946,
          type: 'covered',
          status: 'approved',
          capacity: 20,
          createdAt: now.subtract(const Duration(days: 60)),
        ),
        ParkingSpot(
          id: 'p2',
          ownerId: 'owner_001',
          name: 'Skyline Premier Garage',
          address: 'MG Road, Central Business District, Bangalore',
          rating: 4.8,
          reviewCount: 95,
          pricePerHour: 40,
          distance: 0.4,
          walkTime: 7,
          amenities: ['COVERED', 'CCTV'],
          tags: ['COVERED'],
          imageUrl: 'https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?w=400',
          galleryImages: [
            'https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?w=800',
          ],
          ownerName: 'Arjun Sharma',
          ownerAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
          description: 'Premium covered garage with 24/7 security and CCTV monitoring.',
          latitude: 12.9756,
          longitude: 77.6066,
          type: 'covered',
          status: 'approved',
          capacity: 15,
          createdAt: now.subtract(const Duration(days: 45)),
        ),
        ParkingSpot(
          id: 'p3',
          ownerId: 'owner_001',
          name: 'Plaza Secure Spot',
          address: 'Indiranagar, Old Madras Road, Bangalore',
          rating: 4.6,
          reviewCount: 85,
          pricePerHour: 75,
          distance: 0.7,
          walkTime: 10,
          amenities: ['EV CHARGING', 'VALET'],
          tags: ['EV CHARGING', 'VALET'],
          imageUrl: 'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=400',
          galleryImages: [
            'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=800',
          ],
          ownerName: 'Arjun Sharma',
          ownerAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
          description: 'Modern parking facility with EV charging stations and valet service.',
          latitude: 12.9784,
          longitude: 77.6408,
          type: 'open',
          status: 'approved',
          capacity: 12,
          createdAt: now.subtract(const Duration(days: 30)),
        ),
        ParkingSpot(
          id: 'p4',
          ownerId: 'owner_001',
          name: 'Green Heights Driveway',
          address: 'Koramangala 5th Block, Startup Hub District',
          rating: 4.9,
          reviewCount: 42,
          pricePerHour: 30,
          distance: 1.2,
          walkTime: 15,
          amenities: ['CCTV'],
          tags: ['RESIDENTIAL', 'VERIFIED'],
          imageUrl: 'https://images.unsplash.com/photo-1621929747188-0b4dc28498d2?w=400',
          galleryImages: [
            'https://images.unsplash.com/photo-1621929747188-0b4dc28498d2?w=800',
          ],
          ownerName: 'Arjun Sharma',
          ownerAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
          description: 'Quiet residential driveway parking in a gated community.',
          latitude: 12.9352,
          longitude: 77.6245,
          type: 'open',
          status: 'approved',
          capacity: 5,
          createdAt: now.subtract(const Duration(days: 15)),
        ),
        ParkingSpot(
          id: 'p5',
          ownerId: 'owner_001',
          name: 'Eco-Charge Park',
          address: 'HSR Layout, Sector 2, Bangalore',
          rating: 4.5,
          reviewCount: 67,
          pricePerHour: 35,
          distance: 0.8,
          walkTime: 12,
          amenities: ['EV CHARGING', 'COVERED', 'CCTV'],
          tags: ['EV CHARGING', 'COVERED'],
          imageUrl: 'https://images.unsplash.com/photo-1470224114660-3f6686c562eb?w=400',
          galleryImages: [
            'https://images.unsplash.com/photo-1470224114660-3f6686c562eb?w=800',
          ],
          ownerName: 'Arjun Sharma',
          ownerAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
          description: 'Eco-friendly parking with solar-powered EV charging.',
          latitude: 12.9121,
          longitude: 77.6446,
          type: 'covered',
          status: 'approved',
          capacity: 10,
          createdAt: now.subtract(const Duration(days: 10)),
        ),
      ];
      await saveParkingSpots(spots);
    }

    await prefs.setBool(_dataSeededKey, true);
  }
}
