import 'dart:convert';

import 'package:file_picker/file_picker.dart';
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

  Future<List<MentorRoomQuiz>> getRoomQuizzes(String roomId) async {
    final response = await _client.get(_uri('/api/mentor/room-quizzes/room/$roomId'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong tai duoc danh sach bai kiem tra.'));
    }
    final data = body is List<dynamic> ? body : body['data'] as List<dynamic>? ?? [];
    return data.map((item) => MentorRoomQuiz.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<MentorRoomQuiz> createQuiz(Map<String, dynamic> payload) async {
    final response = await _client.post(
      _uri('/api/mentor/room-quizzes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong tao duoc bai kiem tra.'));
    }
    return MentorRoomQuiz.fromJson(body);
  }

  Future<RoomQuizQuestion> createQuestion(Map<String, dynamic> payload) async {
    final response = await _client.post(
      _uri('/api/mentor/room-quizzes/questions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong tao duoc cau hoi.'));
    }
    return RoomQuizQuestion.fromJson(body);
  }

  Future<RoomQuizOption> createOption(Map<String, dynamic> payload) async {
    final response = await _client.post(
      _uri('/api/mentor/room-quizzes/options'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong tao duoc dap an.'));
    }
    return RoomQuizOption.fromJson(body);
  }

  Future<List<ImportedDocxFile>> getImportedDocxFiles({String? languageId}) async {
    final suffix = languageId == null || languageId.isEmpty ? '' : '?languageId=$languageId';
    final response = await _client.get(_uri('/api/import-docx/files$suffix'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong tai duoc danh sach file DOCX.'));
    }

    final data = body is List<dynamic> ? body : body['data'] as List<dynamic>? ?? [];
    return data.map((item) => ImportedDocxFile.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<ImportedDocxFile> uploadImportedDocx({
    required PlatformFile file,
    String? uploadedBy,
  }) async {
    final request = http.MultipartRequest('POST', _uri('/api/import-docx/upload'));
    if (uploadedBy != null && uploadedBy.isNotEmpty) {
      request.fields['uploadedBy'] = uploadedBy;
    }
    request.files.add(await _multipartFile('file', file));
    final response = await http.Response.fromStream(await _client.send(request));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong upload duoc file DOCX.'));
    }

    final data = body is Map<String, dynamic> ? body['data'] as Map<String, dynamic>? ?? body : <String, dynamic>{};
    return ImportedDocxFile.fromJson(data);
  }

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
    int? levelNumber,
    String? languageId,
    String? importedDocxFileId,
    int maxParticipants = 30,
    String? roomStatus,
    String? hostRole,
    String? accessType,
    num? priceAmount,
    DateTime? scheduledStartAt,
  }) async {
    final response = await _client.post(
      _uri('/api/mentor/rooms'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'hostUserId': hostUserId,
        'roomTitle': roomTitle,
        'levelId': levelId,
        if (levelNumber != null) 'levelNumber': levelNumber,
        'languageId': languageId,
        if (importedDocxFileId != null) 'importedDocxFileId': importedDocxFileId,
        'scheduledStartAt': (scheduledStartAt ?? DateTime.now()).toIso8601String(),
        'maxParticipants': maxParticipants,
        if (roomStatus != null) 'roomStatus': roomStatus,
        if (hostRole != null) 'hostRole': hostRole,
        if (accessType != null) 'accessType': accessType,
        if (priceAmount != null) 'priceAmount': priceAmount,
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

  Future<LearnerRoom> startStudy(String roomId) async {
    final response = await _client.post(_uri('/api/mentor/rooms/$roomId/start-study'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong bat dau duoc buoi hoc.'));
    }

    final data = body is Map<String, dynamic> ? body['data'] as Map<String, dynamic>? ?? body : <String, dynamic>{};
    return LearnerRoom.fromJson({
      ...data,
      'participantCount': data['participantCount'] ?? 0,
    });
  }

  Future<RoomStudyPlan> getRoomStudyPlan(String roomId) async {
    final response = await _client.get(_uri('/api/mentor/rooms/$roomId/study-plan'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong tai duoc noi dung hoc cua phong.'));
    }

    final data = body is Map<String, dynamic> ? body['data'] as Map<String, dynamic>? ?? body : <String, dynamic>{};
    return RoomStudyPlan.fromJson(data);
  }

  Future<void> completeRoomSubLevel({
    required String roomId,
    required String subLevelId,
  }) async {
    final response = await _client.post(_uri('/api/mentor/rooms/$roomId/sublevels/$subLevelId/complete'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong hoan tat duoc sublevel.'));
    }
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

  Future<AttendanceCheck> askAttendance({
    required String roomId,
    required String userId,
    required String levelId,
    required String subLevelId,
  }) async {
    final response = await _client.post(
      _uri('/api/learner/rooms/$roomId/attendance/ask'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'levelId': levelId, 'subLevelId': subLevelId}),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong tao duoc diem danh.'));
    }

    final data = body is Map<String, dynamic> ? body['data'] as Map<String, dynamic>? ?? body : <String, dynamic>{};
    return AttendanceCheck.fromJson(data);
  }

  Future<void> confirmAttendance(String checkId) async {
    final response = await _client.post(_uri('/api/learner/rooms/attendance/$checkId/confirm'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong xac nhan duoc diem danh.'));
    }
  }

  Future<AttendanceEligibility> getAttendanceEligibility({
    required String roomId,
    required String userId,
    required String levelId,
  }) async {
    final response = await _client.get(_uri('/api/learner/rooms/$roomId/eligibility/$userId/$levelId'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong kiem tra duoc dieu kien nhan quiz.'));
    }

    final data = body is Map<String, dynamic> ? body['data'] as Map<String, dynamic>? ?? body : <String, dynamic>{};
    return AttendanceEligibility.fromJson(data);
  }

  Future<RoomQuiz> publishQuiz(String quizId) async {
    final response = await _client.post(_uri('/api/mentor/room-quizzes/$quizId/publish'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong phat duoc bai kiem tra.'));
    }

    final data = body is Map<String, dynamic> ? body['data'] as Map<String, dynamic>? ?? body : <String, dynamic>{};
    return RoomQuiz.fromJson(data);
  }

  Future<QuizSubmitResult> submitQuiz({
    required String quizId,
    required String userId,
    required String roomId,
    required String languageId,
    required String levelId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final response = await _client.post(
      _uri('/api/learner/rooms/room-quizzes/$quizId/submit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'roomId': roomId,
        'languageId': languageId,
        'levelId': levelId,
        'answers': answers,
      }),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong nop duoc bai kiem tra.'));
    }

    final data = body is Map<String, dynamic> ? body['data'] as Map<String, dynamic>? ?? body : <String, dynamic>{};
    return QuizSubmitResult.fromJson(data);
  }

  RoomParticipant _participantFrom(http.Response response, String fallback) {
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, fallback));
    }

    final data = body is Map<String, dynamic> ? body['data'] as Map<String, dynamic>? ?? body : <String, dynamic>{};
    return RoomParticipant.fromJson(data);
  }

  Future<List<CreatorPaidContent>> getCreatorVideos(String creatorUserId) async {
    final response = await _client.get(_uri('/api/creator/contents/creator/$creatorUserId/videos'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong tai duoc video creator.'));
    }
    final data = body is List<dynamic> ? body : body['data'] as List<dynamic>? ?? [];
    return data.map((item) => CreatorPaidContent.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<List<CreatorPaidContent>> getPublishedVideos() async {
    final response = await _client.get(_uri('/api/creator/contents/videos'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong tai duoc video dang ban.'));
    }
    final data = body is List<dynamic> ? body : body['data'] as List<dynamic>? ?? [];
    return data.map((item) => CreatorPaidContent.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<List<CreatorPaidContent>> getPurchasedVideos(String buyerUserId) async {
    final response = await _client.get(_uri('/api/creator/contents/learner/$buyerUserId/videos'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong tai duoc thu vien video da mua.'));
    }
    final data = body is List<dynamic> ? body : body['data'] as List<dynamic>? ?? [];
    return data.map((item) => CreatorPaidContent.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<CreatorPaidContent> uploadCreatorVideo({
    required String creatorUserId,
    required String title,
    required PlatformFile file,
    String? descriptionText,
    num? priceAmount,
  }) async {
    final request = http.MultipartRequest('POST', _uri('/api/creator/contents/videos'))
      ..fields['creatorUserId'] = creatorUserId
      ..fields['title'] = title
      ..fields['descriptionText'] = descriptionText ?? ''
      ..fields['priceAmount'] = '${priceAmount ?? 0}';
    request.files.add(await _multipartFile('file', file));
    return _paidContentFrom(await http.Response.fromStream(await _client.send(request)), 'Khong upload duoc video.');
  }

  Future<CreatorPaidContent> updateCreatorVideo({
    required String contentId,
    String? title,
    String? descriptionText,
    num? priceAmount,
    String? contentStatus,
  }) async {
    final response = await _client.patch(
      _uri('/api/creator/contents/videos/$contentId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (title != null) 'title': title,
        if (descriptionText != null) 'descriptionText': descriptionText,
        if (priceAmount != null) 'priceAmount': priceAmount,
        if (contentStatus != null) 'contentStatus': contentStatus,
      }),
    );
    return _paidContentFrom(response, 'Khong cap nhat duoc video.');
  }

  Future<CreatorPaidContent> replaceCreatorVideoFile({
    required String contentId,
    required PlatformFile file,
  }) async {
    final request = http.MultipartRequest('PUT', _uri('/api/creator/contents/videos/$contentId/file'));
    request.files.add(await _multipartFile('file', file));
    return _paidContentFrom(await http.Response.fromStream(await _client.send(request)), 'Khong thay video moi duoc.');
  }

  Future<void> deleteCreatorVideo(String contentId) async {
    final response = await _client.delete(_uri('/api/creator/contents/videos/$contentId'));
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, 'Khong xoa duoc video.'));
    }
  }

  Future<http.MultipartFile> _multipartFile(String field, PlatformFile file) {
    if (file.bytes != null) {
      return Future.value(http.MultipartFile.fromBytes(field, file.bytes!, filename: file.name));
    }
    if (file.path != null) {
      return http.MultipartFile.fromPath(field, file.path!, filename: file.name);
    }
    throw LmsApiException('File khong co du lieu de upload.');
  }

  CreatorPaidContent _paidContentFrom(http.Response response, String fallback) {
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LmsApiException(_messageFrom(body, fallback));
    }
    final data = body is Map<String, dynamic> ? body['data'] as Map<String, dynamic>? ?? body : <String, dynamic>{};
    return CreatorPaidContent.fromJson(data);
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
    this.importedDocxFileId,
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
  final String? importedDocxFileId;
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
      importedDocxFileId: json['importedDocxFileId'] as String?,
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
      importedDocxFileId: importedDocxFileId,
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
    this.accessType,
    this.priceAmount,
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
  final String? accessType;
  final num? priceAmount;

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
      accessType: room.accessType,
      priceAmount: room.priceAmount,
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
      accessType: json['accessType'] as String?,
      priceAmount: LearnerRoom._numOrNull(json['priceAmount']),
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
    super.accessType,
    super.priceAmount,
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
      accessType: room.accessType,
      priceAmount: room.priceAmount,
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

class CreatorPaidContent {
  const CreatorPaidContent({
    required this.contentId,
    required this.creatorUserId,
    required this.title,
    required this.contentType,
    required this.contentStatus,
    required this.priceAmount,
    this.descriptionText,
    this.mediaUrl,
    this.publishedAt,
  });

  final String contentId;
  final String creatorUserId;
  final String title;
  final String contentType;
  final String contentStatus;
  final num priceAmount;
  final String? descriptionText;
  final String? mediaUrl;
  final String? publishedAt;

  String absoluteMediaUrl(String baseUrl) {
    if (mediaUrl == null || mediaUrl!.isEmpty) return '';
    if (mediaUrl!.startsWith('http://') || mediaUrl!.startsWith('https://')) return mediaUrl!;
    return '$baseUrl$mediaUrl';
  }

  String get displayPrice => priceAmount <= 0 ? 'Mien phi' : '${priceAmount.toStringAsFixed(0)} Xu';

  factory CreatorPaidContent.fromJson(Map<String, dynamic> json) {
    return CreatorPaidContent(
      contentId: '${json['contentId'] ?? ''}',
      creatorUserId: '${json['creatorUserId'] ?? ''}',
      title: '${json['title'] ?? ''}',
      contentType: '${json['contentType'] ?? ''}',
      contentStatus: '${json['contentStatus'] ?? ''}',
      priceAmount: LearnerRoom._numOrNull(json['priceAmount']) ?? 0,
      descriptionText: json['descriptionText'] as String?,
      mediaUrl: (json['mediaUrl'] ?? json['audioUrl']) as String?,
      publishedAt: json['publishedAt'] as String?,
    );
  }
}

class ImportedDocxFile {
  const ImportedDocxFile({
    required this.importedDocxFileId,
    required this.fileName,
    required this.filePath,
    required this.importStatus,
    this.languageId,
    this.stageId,
    this.levelStart,
    this.levelEnd,
    this.errorMessage,
  });

  final String importedDocxFileId;
  final String fileName;
  final String filePath;
  final String importStatus;
  final String? languageId;
  final String? stageId;
  final int? levelStart;
  final int? levelEnd;
  final String? errorMessage;

  bool get isImported => importStatus.toUpperCase() == 'IMPORTED';

  factory ImportedDocxFile.fromJson(Map<String, dynamic> json) {
    return ImportedDocxFile(
      importedDocxFileId: '${json['importedDocxFileId'] ?? ''}',
      fileName: '${json['fileName'] ?? ''}',
      filePath: '${json['filePath'] ?? ''}',
      importStatus: '${json['importStatus'] ?? ''}',
      languageId: json['languageId'] as String?,
      stageId: json['stageId'] as String?,
      levelStart: LearnerRoom._intOrNull(json['levelStart']),
      levelEnd: LearnerRoom._intOrNull(json['levelEnd']),
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

class RoomStudyPlan {
  const RoomStudyPlan({
    required this.subLevels,
    this.importedDocxFile,
    this.levelTitle,
    this.levelDescription,
    this.groupTitle,
  });

  final ImportedDocxFile? importedDocxFile;
  final String? levelTitle;
  final String? levelDescription;
  final String? groupTitle;
  final List<StudySubLevel> subLevels;

  factory RoomStudyPlan.fromJson(Map<String, dynamic> json) {
    final level = json['level'] is Map ? Map<String, dynamic>.from(json['level'] as Map) : <String, dynamic>{};
    final group = json['levelGroup'] is Map ? Map<String, dynamic>.from(json['levelGroup'] as Map) : <String, dynamic>{};
    final file = json['importedDocxFile'] is Map ? Map<String, dynamic>.from(json['importedDocxFile'] as Map) : null;
    final subLevelsJson = json['subLevels'] as List<dynamic>? ?? [];
    return RoomStudyPlan(
      importedDocxFile: file == null ? null : ImportedDocxFile.fromJson(file),
      levelTitle: level['levelTitle'] as String?,
      levelDescription: level['levelDescription'] as String?,
      groupTitle: group['groupTitle'] as String?,
      subLevels: subLevelsJson.map((item) => StudySubLevel.fromJson(Map<String, dynamic>.from(item as Map))).toList(),
    );
  }
}

class StudySubLevel {
  const StudySubLevel({
    required this.subLevelId,
    required this.title,
    required this.status,
    this.mainTask,
    this.promptHint,
    this.durationMins,
  });

  final String subLevelId;
  final String title;
  final String status;
  final String? mainTask;
  final String? promptHint;
  final int? durationMins;

  factory StudySubLevel.fromJson(Map<String, dynamic> json) {
    final subLevel = json['subLevel'] is Map ? Map<String, dynamic>.from(json['subLevel'] as Map) : <String, dynamic>{};
    final roomSubLevel = json['roomSubLevel'] is Map ? Map<String, dynamic>.from(json['roomSubLevel'] as Map) : <String, dynamic>{};
    return StudySubLevel(
      subLevelId: '${subLevel['subLevelId'] ?? ''}',
      title: '${subLevel['sublevelTitle'] ?? 'Sublevel'}',
      mainTask: subLevel['mainTask'] as String?,
      promptHint: subLevel['promptHint'] as String?,
      durationMins: LearnerRoom._intOrNull(subLevel['subDurationMins'] ?? roomSubLevel['plannedDurationMins']),
      status: '${roomSubLevel['status'] ?? 'NOT_STARTED'}',
    );
  }
}

class AttendanceCheck {
  const AttendanceCheck({required this.checkId, required this.learningSessionId});

  final String checkId;
  final String learningSessionId;

  factory AttendanceCheck.fromJson(Map<String, dynamic> json) {
    return AttendanceCheck(
      checkId: '${json['checkId'] ?? ''}',
      learningSessionId: '${json['learningSessionId'] ?? ''}',
    );
  }
}

class AttendanceEligibility {
  const AttendanceEligibility({
    required this.offlineCount,
    required this.eligibleForQuiz,
  });

  final int offlineCount;
  final bool eligibleForQuiz;

  factory AttendanceEligibility.fromJson(Map<String, dynamic> json) {
    return AttendanceEligibility(
      offlineCount: LearnerRoom._intOrZero(json['offlineCount']),
      eligibleForQuiz: json['eligibleForQuiz'] == true,
    );
  }
}

class RoomQuiz {
  const RoomQuiz({
    required this.quizId,
    required this.quizTitle,
    required this.quizStatus,
    this.durationMinutes,
  });

  final String quizId;
  final String quizTitle;
  final String quizStatus;
  final int? durationMinutes;

  factory RoomQuiz.fromJson(Map<String, dynamic> json) {
    return RoomQuiz(
      quizId: '${json['quizId'] ?? ''}',
      quizTitle: '${json['quizTitle'] ?? ''}',
      quizStatus: '${json['quizStatus'] ?? ''}',
      durationMinutes: LearnerRoom._intOrNull(json['durationMinutes']),
    );
  }
}

class QuizSubmitResult {
  const QuizSubmitResult({
    required this.attemptId,
    required this.scorePercent,
    required this.passed,
  });

  final String attemptId;
  final num scorePercent;
  final bool passed;

  factory QuizSubmitResult.fromJson(Map<String, dynamic> json) {
    return QuizSubmitResult(
      attemptId: '${json['attemptId'] ?? ''}',
      scorePercent: LearnerRoom._numOrNull(json['scorePercent']) ?? 0,
      passed: json['passed'] == true,
    );
  }
}

class MentorRoomQuiz {
  const MentorRoomQuiz({
    required this.quizId,
    required this.roomId,
    required this.title,
    this.description,
    required this.quizType,
    required this.status,
    required this.passingScore,
  });

  final String quizId;
  final String roomId;
  final String title;
  final String? description;
  final String quizType;
  final String status;
  final num passingScore;

  factory MentorRoomQuiz.fromJson(Map<String, dynamic> json) {
    return MentorRoomQuiz(
      quizId: '${json['quizId'] ?? ''}',
      roomId: '${json['roomId'] ?? ''}',
      title: '${json['title'] ?? ''}',
      description: json['description'] as String?,
      quizType: '${json['quizType'] ?? 'MULTIPLE_CHOICE'}',
      status: '${json['status'] ?? 'DRAFT'}',
      passingScore: json['passingScore'] is num ? (json['passingScore'] as num) : num.tryParse('${json['passingScore']}') ?? 80,
    );
  }
}

class RoomQuizQuestion {
  const RoomQuizQuestion({
    required this.questionId,
    required this.quizId,
    required this.content,
    required this.questionType,
    required this.points,
  });

  final String questionId;
  final String quizId;
  final String content;
  final String questionType;
  final num points;

  factory RoomQuizQuestion.fromJson(Map<String, dynamic> json) {
    return RoomQuizQuestion(
      questionId: '${json['questionId'] ?? ''}',
      quizId: '${json['quizId'] ?? ''}',
      content: '${json['content'] ?? ''}',
      questionType: '${json['questionType'] ?? 'SINGLE_CHOICE'}',
      points: json['points'] is num ? (json['points'] as num) : num.tryParse('${json['points']}') ?? 10,
    );
  }
}

class RoomQuizOption {
  const RoomQuizOption({
    required this.optionId,
    required this.questionId,
    required this.content,
    required this.isCorrect,
  });

  final String optionId;
  final String questionId;
  final String content;
  final bool isCorrect;

  factory RoomQuizOption.fromJson(Map<String, dynamic> json) {
    bool correct = false;
    if (json['isCorrect'] is bool) {
      correct = json['isCorrect'] as bool;
    } else if (json['isCorrect'] is num) {
      correct = (json['isCorrect'] as num) > 0;
    }
    return RoomQuizOption(
      optionId: '${json['optionId'] ?? ''}',
      questionId: '${json['questionId'] ?? ''}',
      content: '${json['content'] ?? ''}',
      isCorrect: correct,
    );
  }
}

class LmsApiException implements Exception {
  LmsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
