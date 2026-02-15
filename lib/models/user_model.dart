import 'dart:convert';

/// User roles in the system: Admin, User (driver), Owner
enum UserRole { admin, user, owner }

/// Owner approval status for admin verification
enum ApprovalStatus { pending, approved, rejected }

/// Model representing a user (driver or owner)
class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String password;
  final String avatarUrl;
  final UserRole role;
  final bool isVerifiedOwner;
  final ApprovalStatus approvalStatus;
  final int totalBookings;
  final int totalParkings;
  final double earnings;

  const UserModel({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.password = '',
    this.avatarUrl = '',
    this.role = UserRole.user,
    this.isVerifiedOwner = false,
    this.approvalStatus = ApprovalStatus.approved, // Users and admins are auto-approved
    this.totalBookings = 0,
    this.totalParkings = 0,
    this.earnings = 0.0,
  });

  /// Convert to JSON map for local storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'avatarUrl': avatarUrl,
        'role': role.name,
        'isVerifiedOwner': isVerifiedOwner,
        'approvalStatus': approvalStatus.name,
        'totalBookings': totalBookings,
        'totalParkings': totalParkings,
        'earnings': earnings,
      };

  /// Create from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
        role: UserRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => UserRole.user,
        ),
        isVerifiedOwner: json['isVerifiedOwner'] ?? false,
        approvalStatus: ApprovalStatus.values.firstWhere(
          (s) => s.name == json['approvalStatus'],
          orElse: () => ApprovalStatus.approved, // Backward compatibility
        ),
        totalBookings: json['totalBookings'] ?? 0,
        totalParkings: json['totalParkings'] ?? 0,
        earnings: (json['earnings'] ?? 0.0).toDouble(),
      );

  /// Serialize to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Deserialize from JSON string
  factory UserModel.fromJsonString(String jsonStr) =>
      UserModel.fromJson(jsonDecode(jsonStr));

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? password,
    String? avatarUrl,
    UserRole? role,
    bool? isVerifiedOwner,
    ApprovalStatus? approvalStatus,
    int? totalBookings,
    int? totalParkings,
    double? earnings,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        password: password ?? this.password,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        role: role ?? this.role,
        isVerifiedOwner: isVerifiedOwner ?? this.isVerifiedOwner,
        approvalStatus: approvalStatus ?? this.approvalStatus,
        totalBookings: totalBookings ?? this.totalBookings,
        totalParkings: totalParkings ?? this.totalParkings,
        earnings: earnings ?? this.earnings,
      );

  /// Display-friendly role name
  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.owner:
        return 'Parking Owner';
      case UserRole.user:
        return 'Driver';
    }
  }

  /// Check if user is an approved owner who can perform owner actions
  bool get canPerformOwnerActions {
    return role == UserRole.owner && approvalStatus == ApprovalStatus.approved;
  }

  /// Check if user is pending admin approval
  bool get isPendingApproval {
    return role == UserRole.owner && approvalStatus == ApprovalStatus.pending;
  }

  /// Check if user registration was rejected
  bool get isRejected {
    return approvalStatus == ApprovalStatus.rejected;
  }

  /// Get approval status display text
  String get approvalStatusText {
    switch (approvalStatus) {
      case ApprovalStatus.pending:
        return 'Pending Admin Approval';
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Registration Rejected';
    }
  }
}
