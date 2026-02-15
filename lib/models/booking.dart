import 'dart:convert';

/// Model representing a parking booking
class Booking {
  final String id;
  final String userId; // who booked
  final String ownerId; // who owns the spot
  final String parkingSpotId;
  final String parkingName;
  final String parkingAddress;
  final String parkingImage;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final double basePrice;
  final double serviceFee;
  final double gst;
  final String status; // confirmed, active, completed, cancelled
  final String paymentMethod;
  final String userName; // name of the person who booked

  const Booking({
    required this.id,
    this.userId = '',
    this.ownerId = '',
    required this.parkingSpotId,
    required this.parkingName,
    required this.parkingAddress,
    required this.parkingImage,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.basePrice,
    required this.serviceFee,
    required this.gst,
    this.status = 'confirmed',
    this.paymentMethod = 'Visa •••• 4242',
    this.userName = '',
  });

  /// Duration in hours
  double get durationHours =>
      endTime.difference(startTime).inMinutes / 60.0;

  /// Formatted duration string
  String get durationFormatted {
    final hours = endTime.difference(startTime).inHours;
    final mins = endTime.difference(startTime).inMinutes % 60;
    if (mins == 0) return '$hours Hours';
    return '$hours hours $mins mins';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'ownerId': ownerId,
        'parkingSpotId': parkingSpotId,
        'parkingName': parkingName,
        'parkingAddress': parkingAddress,
        'parkingImage': parkingImage,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'totalPrice': totalPrice,
        'basePrice': basePrice,
        'serviceFee': serviceFee,
        'gst': gst,
        'status': status,
        'paymentMethod': paymentMethod,
        'userName': userName,
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        ownerId: json['ownerId'] ?? '',
        parkingSpotId: json['parkingSpotId'] ?? '',
        parkingName: json['parkingName'] ?? '',
        parkingAddress: json['parkingAddress'] ?? '',
        parkingImage: json['parkingImage'] ?? '',
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
        totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
        basePrice: (json['basePrice'] ?? 0.0).toDouble(),
        serviceFee: (json['serviceFee'] ?? 0.0).toDouble(),
        gst: (json['gst'] ?? 0.0).toDouble(),
        status: json['status'] ?? 'confirmed',
        paymentMethod: json['paymentMethod'] ?? '',
        userName: json['userName'] ?? '',
      );

  String toJsonString() => jsonEncode(toJson());
  factory Booking.fromJsonString(String s) =>
      Booking.fromJson(jsonDecode(s));

  Booking copyWith({
    String? id,
    String? userId,
    String? ownerId,
    String? parkingSpotId,
    String? parkingName,
    String? parkingAddress,
    String? parkingImage,
    DateTime? startTime,
    DateTime? endTime,
    double? totalPrice,
    double? basePrice,
    double? serviceFee,
    double? gst,
    String? status,
    String? paymentMethod,
    String? userName,
  }) =>
      Booking(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        ownerId: ownerId ?? this.ownerId,
        parkingSpotId: parkingSpotId ?? this.parkingSpotId,
        parkingName: parkingName ?? this.parkingName,
        parkingAddress: parkingAddress ?? this.parkingAddress,
        parkingImage: parkingImage ?? this.parkingImage,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        totalPrice: totalPrice ?? this.totalPrice,
        basePrice: basePrice ?? this.basePrice,
        serviceFee: serviceFee ?? this.serviceFee,
        gst: gst ?? this.gst,
        status: status ?? this.status,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        userName: userName ?? this.userName,
      );
}
