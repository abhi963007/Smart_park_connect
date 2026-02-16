import 'dart:convert';

/// Represents a single chat message between two users
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] ?? '',
        senderId: json['senderId'] ?? '',
        senderName: json['senderName'] ?? '',
        receiverId: json['receiverId'] ?? '',
        receiverName: json['receiverName'] ?? '',
        message: json['message'] ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
        isRead: json['isRead'] ?? false,
      );

  String toJsonString() => jsonEncode(toJson());
  factory ChatMessage.fromJsonString(String s) =>
      ChatMessage.fromJson(jsonDecode(s));

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? receiverName,
    String? message,
    DateTime? timestamp,
    bool? isRead,
  }) =>
      ChatMessage(
        id: id ?? this.id,
        senderId: senderId ?? this.senderId,
        senderName: senderName ?? this.senderName,
        receiverId: receiverId ?? this.receiverId,
        receiverName: receiverName ?? this.receiverName,
        message: message ?? this.message,
        timestamp: timestamp ?? this.timestamp,
        isRead: isRead ?? this.isRead,
      );
}

/// Represents a conversation thread between two users
class Conversation {
  final String id;
  final String user1Id;
  final String user1Name;
  final String user2Id;
  final String user2Name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.user1Id,
    required this.user1Name,
    required this.user2Id,
    required this.user2Name,
    this.lastMessage = '',
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user1Id': user1Id,
        'user1Name': user1Name,
        'user2Id': user2Id,
        'user2Name': user2Name,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime.toIso8601String(),
        'unreadCount': unreadCount,
      };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] ?? '',
        user1Id: json['user1Id'] ?? '',
        user1Name: json['user1Name'] ?? '',
        user2Id: json['user2Id'] ?? '',
        user2Name: json['user2Name'] ?? '',
        lastMessage: json['lastMessage'] ?? '',
        lastMessageTime: json['lastMessageTime'] != null
            ? DateTime.parse(json['lastMessageTime'])
            : DateTime.now(),
        unreadCount: json['unreadCount'] ?? 0,
      );

  String toJsonString() => jsonEncode(toJson());
  factory Conversation.fromJsonString(String s) =>
      Conversation.fromJson(jsonDecode(s));

  Conversation copyWith({
    String? id,
    String? user1Id,
    String? user1Name,
    String? user2Id,
    String? user2Name,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) =>
      Conversation(
        id: id ?? this.id,
        user1Id: user1Id ?? this.user1Id,
        user1Name: user1Name ?? this.user1Name,
        user2Id: user2Id ?? this.user2Id,
        user2Name: user2Name ?? this.user2Name,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,
        unreadCount: unreadCount ?? this.unreadCount,
      );

  /// Get the other user's name given the current user's ID
  String otherUserName(String currentUserId) =>
      currentUserId == user1Id ? user2Name : user1Name;

  /// Get the other user's ID given the current user's ID
  String otherUserId(String currentUserId) =>
      currentUserId == user1Id ? user2Id : user1Id;
}
