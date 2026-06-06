import 'dart:convert';

import 'package:http/http.dart' as http;

class LmsApi {
  LmsApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ??
            const String.fromEnvironment(
              'LUCY_LMS_API_URL',
              defaultValue: 'http://localhost:8080',
            );

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<LearnerRoom>> getLearnerRooms() async {
    final response = await _client.get(_uri('/api/learner/rooms'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong tai duoc danh sach phong.'));
    }

    final data = body is List<dynamic> ? body : body['data'] as List<dynamic>? ?? [];
    return data.map((item) => LearnerRoom.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<LmsRoom>> getAllRooms() async {
    final rooms = await getLearnerRooms();
    return rooms.map(LmsRoom.fromLearnerRoom).toList();
  }

  Future<List<LmsRoomHistory>> getJoinedRoomHistory(String userId) async {
    final response = await _client.get(_uri('/api/learner/rooms/history/$userId'));
    if (response.statusCode == 404) return [];

    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong tai duoc lich su phong da tham gia.'));
    }

    final data = body is List<dynamic> ? body : body['data'] as List<dynamic>? ?? [];
    return data.map((item) => LmsRoomHistory.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<LearnerRoom> createMentorRoom({
    required String hostUserId,
    required String roomTitle,
    String? levelId,
    String? languageId,
    int maxParticipants = 30,
    String? roomStatus,
    DateTime? scheduledStartAt,
  }) async {
    final response = await _client.post(
      _uri('/api/mentor/rooms'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'hostUserId': hostUserId,
        'roomTitle': roomTitle,
        'levelId': levelId,
        'languageId': languageId,
        'scheduledStartAt': (scheduledStartAt ?? DateTime.now()).toIso8601String(),
        'maxParticipants': maxParticipants,
        if (roomStatus != null) 'roomStatus': roomStatus,
      }),
    );

    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong tao duoc phong mentor.'));
    }

    final data = body is Map<String, dynamic> ? body['data'] as Map<String, dynamic>? ?? body : <String, dynamic>{};
    return LearnerRoom.fromJson({
      ...data,
      'participantCount': data['participantCount'] ?? 0,
    });
  }

  Future<List<LearnerRoom>> getMentorRooms(String hostUserId) async {
    final response = await _client.get(_uri('/api/mentor/rooms/mentor/$hostUserId'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong tai duoc danh sach phong mentor.'));
    }

    final data = body is List<dynamic> ? body : body['data'] as List<dynamic>? ?? [];
    return data.map((item) {
      final json = Map<String, dynamic>.from(item as Map);
      json['participantCount'] = json['participantCount'] ?? 0;
      return LearnerRoom.fromJson(json);
    }).toList();
  }

  Future<LearnerRoom> endMentorRoom(String roomId) async {
    final response = await _client.post(_uri('/api/mentor/rooms/$roomId/end'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong ket thuc duoc phong mentor.'));
    }

    final data = body is Map<String, dynamic> ? body['data'] as Map<String, dynamic>? ?? body : <String, dynamic>{};
    return LearnerRoom.fromJson({
      ...data,
      'participantCount': data['participantCount'] ?? 0,
    });
  }

  Future<LearnerRoom> openMentorRoom(String roomId) async {
    final response = await _client.post(_uri('/api/mentor/rooms/$roomId/open'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong mo duoc phong mentor.'));
    }

    final data = body is Map<String, dynamic> ? body['data'] as Map<String, dynamic>? ?? body : <String, dynamic>{};
    return LearnerRoom.fromJson({
      ...data,
      'participantCount': data['participantCount'] ?? 0,
    });
  }

  Future<RoomParticipant> joinRoom({
    required String roomId,
    required String userId,
  }) async {
    final response = await _client.post(
      _uri('/api/learner/rooms/$roomId/join'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    return _participantFrom(response, 'Khong the tham gia phong.');
  }

  Future<RoomParticipant> leaveRoom({
    required String roomId,
    required String userId,
  }) async {
    final response = await _client.post(
      _uri('/api/learner/rooms/$roomId/leave'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    return _participantFrom(response, 'Khong the roi phong.');
  }

  Future<RoomParticipant> updateMic({
    required String roomId,
    required String userId,
    required bool enabled,
  }) async {
    final response = await _client.patch(
      _uri('/api/learner/rooms/$roomId/mic'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'enabled': enabled}),
    );
    return _participantFrom(response, 'Khong cap nhat duoc micro.');
  }

  Future<RoomParticipant> updateHandRaise({
    required String roomId,
    required String userId,
    required bool raised,
  }) async {
    final response = await _client.patch(
      _uri('/api/learner/rooms/$roomId/hand-raise'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'raised': raised}),
    );
    return _participantFrom(response, 'Khong cap nhat duoc trang thai gio tay.');
  }

  RoomParticipant _participantFrom(http.Response response, String fallback) {
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, fallback));
    }

    final data = body is Map<String, dynamic> ? body['data'] as Map<String, dynamic>? ?? body : <String, dynamic>{};
    return RoomParticipant.fromJson(data);
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return decoded;
  }

  String _messageFrom(dynamic body, String fallback) {
    if (body is Map<String, dynamic>) {
      return '${body['message'] ?? body['error'] ?? fallback}';
    }
    return fallback;
  }
}

class LearnerRoom {
  const LearnerRoom({
    required this.roomId,
    required this.hostUserId,
    required this.roomTitle,
    required this.roomStatus,
    required this.participantCount,
    this.levelId,
    this.languageId,
    this.roomType,
    this.accessType,
    this.priceAmount,
    this.maxParticipants,
    this.scheduledStartAt,
    this.hostUserName,
  });

  final String roomId;
  final String hostUserId;
  final String roomTitle;
  final String roomStatus;
  final int participantCount;
  final String? levelId;
  final String? languageId;
  final String? roomType;
  final String? accessType;
  final num? priceAmount;
  final int? maxParticipants;
  final String? scheduledStartAt;
  final String? hostUserName;

  factory LearnerRoom.fromJson(Map<String, dynamic> json) {
    return LearnerRoom(
      roomId: '${json['roomId'] ?? ''}',
      hostUserId: '${json['hostUserId'] ?? ''}',
      roomTitle: '${json['roomTitle'] ?? ''}',
      roomStatus: '${json['roomStatus'] ?? ''}',
      participantCount: _intOrZero(json['participantCount']),
      levelId: json['levelId'] as String?,
      languageId: json['languageId'] as String?,
      roomType: json['roomType'] as String?,
      accessType: json['accessType'] as String?,
      priceAmount: _numOrNull(json['priceAmount']),
      maxParticipants: _intOrNull(json['maxParticipants']),
      scheduledStartAt: json['scheduledStartAt'] as String?,
      hostUserName: json['hostUserName'] as String?,
    );
  }

  LearnerRoom copyWith({
    int? participantCount,
  }) {
    return LearnerRoom(
      roomId: roomId,
      hostUserId: hostUserId,
      roomTitle: roomTitle,
      roomStatus: roomStatus,
      participantCount: participantCount ?? this.participantCount,
      levelId: levelId,
      languageId: languageId,
      roomType: roomType,
      accessType: accessType,
      priceAmount: priceAmount,
      maxParticipants: maxParticipants,
      scheduledStartAt: scheduledStartAt,
      hostUserName: hostUserName,
    );
  }

  static int _intOrZero(Object? value) => _intOrNull(value) ?? 0;

  static int? _intOrNull(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static num? _numOrNull(Object? value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}

class LmsRoom {
  const LmsRoom({
    required this.roomId,
    required this.hostUserId,
    required this.roomTitle,
    required this.roomStatus,
    required this.participantCount,
    this.levelId,
    this.languageId,
    this.maxParticipants,
    this.scheduledStartAt,
    this.mentorName,
    this.levelNumber,
  });

  final String roomId;
  final String hostUserId;
  final String roomTitle;
  final String roomStatus;
  final int participantCount;
  final String? levelId;
  final String? languageId;
  final int? maxParticipants;
  final String? scheduledStartAt;
  final String? mentorName;
  final int? levelNumber;

  factory LmsRoom.fromLearnerRoom(LearnerRoom room) {
    return LmsRoom(
      roomId: room.roomId,
      hostUserId: room.hostUserId,
      roomTitle: room.roomTitle,
      roomStatus: room.roomStatus,
      participantCount: room.participantCount,
      levelId: room.levelId,
      languageId: room.languageId,
      maxParticipants: room.maxParticipants,
      scheduledStartAt: room.scheduledStartAt,
      mentorName: room.hostUserName,
      levelNumber: _levelNumberFromLevelId(room.levelId),
    );
  }

  factory LmsRoom.fromJson(Map<String, dynamic> json) {
    return LmsRoom(
      roomId: '${json['roomId'] ?? ''}',
      hostUserId: '${json['hostUserId'] ?? ''}',
      roomTitle: '${json['roomTitle'] ?? ''}',
      roomStatus: '${json['roomStatus'] ?? ''}',
      participantCount: LearnerRoom._intOrZero(json['participantCount']),
      levelId: json['levelId'] as String?,
      languageId: json['languageId'] as String?,
      maxParticipants: LearnerRoom._intOrNull(json['maxParticipants']),
      scheduledStartAt: json['scheduledStartAt'] as String?,
      mentorName: (json['mentorName'] ?? json['hostUserName']) as String?,
      levelNumber: LearnerRoom._intOrNull(json['levelNumber']) ?? _levelNumberFromLevelId(json['levelId'] as String?),
    );
  }

  static int? _levelNumberFromLevelId(String? levelId) {
    if (levelId == null) return null;
    final match = RegExp(r'\d+').firstMatch(levelId);
    return match == null ? null : int.tryParse(match.group(0)!);
  }
}

class LmsRoomHistory extends LmsRoom {
  const LmsRoomHistory({
    required super.roomId,
    required super.hostUserId,
    required super.roomTitle,
    required super.roomStatus,
    required super.participantCount,
    super.levelId,
    super.languageId,
    super.maxParticipants,
    super.scheduledStartAt,
    super.mentorName,
    super.levelNumber,
    this.endedAt,
  });

  final DateTime? endedAt;

  factory LmsRoomHistory.fromJson(Map<String, dynamic> json) {
    final room = LmsRoom.fromJson(json);
    return LmsRoomHistory(
      roomId: room.roomId,
      hostUserId: room.hostUserId,
      roomTitle: room.roomTitle,
      roomStatus: room.roomStatus,
      participantCount: room.participantCount,
      levelId: room.levelId,
      languageId: room.languageId,
      maxParticipants: room.maxParticipants,
      scheduledStartAt: room.scheduledStartAt,
      mentorName: room.mentorName,
      levelNumber: room.levelNumber,
      endedAt: _dateTimeOrNull(json['endedAt'] ?? json['leftAt']),
    );
  }

  static DateTime? _dateTimeOrNull(Object? value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}

class RoomParticipant {
  const RoomParticipant({
    required this.participantId,
    required this.roomId,
    required this.userId,
    required this.micStatus,
    required this.handRaiseStatus,
    required this.participantStatus,
  });

  final String participantId;
  final String roomId;
  final String userId;
  final String micStatus;
  final String handRaiseStatus;
  final String participantStatus;

  bool get isMicOn => micStatus.toUpperCase() == 'ON';
  bool get isHandRaised => handRaiseStatus.toUpperCase() == 'RAISED';

  factory RoomParticipant.fromJson(Map<String, dynamic> json) {
    return RoomParticipant(
      participantId: '${json['participantId'] ?? ''}',
      roomId: '${json['roomId'] ?? ''}',
      userId: '${json['userId'] ?? ''}',
      micStatus: '${json['micStatus'] ?? 'OFF'}',
      handRaiseStatus: '${json['handRaiseStatus'] ?? 'NONE'}',
      participantStatus: '${json['participantStatus'] ?? 'JOINED'}',
    );
  }
}

class LmsApiException implements Exception {
  LmsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
