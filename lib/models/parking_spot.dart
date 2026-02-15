import 'dart:convert';

/// Model representing a parking space listing
class ParkingSpot {
  final String id;
  final String ownerId; // links to UserModel.id
  final String name;
  final String address;
  final double rating;
  final int reviewCount;
  final double pricePerHour;
  final double distance; // in km
  final int walkTime; // in minutes
  final List<String> amenities; // e.g. COVERED, CCTV, EV CHARGING, VALET, 24/7
  final List<String> tags; // e.g. RESIDENTIAL, VERIFIED
  final String imageUrl;
  final List<String> galleryImages;
  final String ownerName;
  final String ownerAvatar;
  final String description;
  final double latitude;
  final double longitude;
  final bool isAvailable;
  final String type; // covered, open, underground
  final String status; // approved, pending, rejected
  final int capacity;
  final DateTime createdAt;

  const ParkingSpot({
    required this.id,
    this.ownerId = '',
    required this.name,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.pricePerHour,
    required this.distance,
    required this.walkTime,
    required this.amenities,
    required this.tags,
    required this.imageUrl,
    required this.galleryImages,
    required this.ownerName,
    required this.ownerAvatar,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.isAvailable = true,
    this.type = 'covered',
    this.status = 'approved',
    this.capacity = 10,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'name': name,
        'address': address,
        'rating': rating,
        'reviewCount': reviewCount,
        'pricePerHour': pricePerHour,
        'distance': distance,
        'walkTime': walkTime,
        'amenities': amenities,
        'tags': tags,
        'imageUrl': imageUrl,
        'galleryImages': galleryImages,
        'ownerName': ownerName,
        'ownerAvatar': ownerAvatar,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'isAvailable': isAvailable,
        'type': type,
        'status': status,
        'capacity': capacity,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ParkingSpot.fromJson(Map<String, dynamic> json) => ParkingSpot(
        id: json['id'] ?? '',
        ownerId: json['ownerId'] ?? '',
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        rating: (json['rating'] ?? 0.0).toDouble(),
        reviewCount: json['reviewCount'] ?? 0,
        pricePerHour: (json['pricePerHour'] ?? 0.0).toDouble(),
        distance: (json['distance'] ?? 0.0).toDouble(),
        walkTime: json['walkTime'] ?? 0,
        amenities: List<String>.from(json['amenities'] ?? []),
        tags: List<String>.from(json['tags'] ?? []),
        imageUrl: json['imageUrl'] ?? '',
        galleryImages: List<String>.from(json['galleryImages'] ?? []),
        ownerName: json['ownerName'] ?? '',
        ownerAvatar: json['ownerAvatar'] ?? '',
        description: json['description'] ?? '',
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        longitude: (json['longitude'] ?? 0.0).toDouble(),
        isAvailable: json['isAvailable'] ?? true,
        type: json['type'] ?? 'covered',
        status: json['status'] ?? 'approved',
        capacity: json['capacity'] ?? 10,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );

  String toJsonString() => jsonEncode(toJson());
  factory ParkingSpot.fromJsonString(String s) =>
      ParkingSpot.fromJson(jsonDecode(s));

  ParkingSpot copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? address,
    double? rating,
    int? reviewCount,
    double? pricePerHour,
    double? distance,
    int? walkTime,
    List<String>? amenities,
    List<String>? tags,
    String? imageUrl,
    List<String>? galleryImages,
    String? ownerName,
    String? ownerAvatar,
    String? description,
    double? latitude,
    double? longitude,
    bool? isAvailable,
    String? type,
    String? status,
    int? capacity,
    DateTime? createdAt,
  }) =>
      ParkingSpot(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        name: name ?? this.name,
        address: address ?? this.address,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        pricePerHour: pricePerHour ?? this.pricePerHour,
        distance: distance ?? this.distance,
        walkTime: walkTime ?? this.walkTime,
        amenities: amenities ?? this.amenities,
        tags: tags ?? this.tags,
        imageUrl: imageUrl ?? this.imageUrl,
        galleryImages: galleryImages ?? this.galleryImages,
        ownerName: ownerName ?? this.ownerName,
        ownerAvatar: ownerAvatar ?? this.ownerAvatar,
        description: description ?? this.description,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        isAvailable: isAvailable ?? this.isAvailable,
        type: type ?? this.type,
        status: status ?? this.status,
        capacity: capacity ?? this.capacity,
        createdAt: createdAt ?? this.createdAt,
      );
}
