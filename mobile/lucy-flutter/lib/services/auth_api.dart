import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class AuthApi {
  AuthApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ??
            const String.fromEnvironment(
              'LUCY_AUTH_API_URL',
              defaultValue: 'http://localhost:5257',
            );

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<AuthSession> registerLearner({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _client.post(
      _uri('/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
      }),
    );

    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_messageFrom(body, 'Dang ky khong thanh cong.'));
    }

    return AuthSession.fromAuthResponse(body);
  }

  Future<void> registerMentor({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    PlatformFile? certificateFile,
  }) async {
    final request = http.MultipartRequest('POST', _uri('/api/auth/register-mentor'))
      ..fields['fullName'] = fullName
      ..fields['email'] = email
      ..fields['phoneNumber'] = phoneNumber
      ..fields['password'] = password;

    if (certificateFile != null) {
      request.files.add(await _multipartFile('certificateFile', certificateFile));
    }

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    final body = _decode(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_messageFrom(body, 'Dang ky mentor khong thanh cong.'));
    }
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _uri('/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_messageFrom(body, 'Dang nhap khong thanh cong.'));
    }

    return AuthSession.fromAuthResponse(body);
  }

  Future<void> forgotPassword(String email) async {
    final response = await _client.post(
      _uri('/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_messageFrom(body, 'Yêu cầu gửi mã OTP thất bại.'));
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    final response = await _client.post(
      _uri('/api/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_messageFrom(body, 'Mã OTP không hợp lệ.'));
    }
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    final response = await _client.post(
      _uri('/api/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_messageFrom(body, 'Đặt lại mật khẩu thất bại.'));
    }
  }

  Future<AuthSession> updateAvatar({
    required String token,
    String? displayName,
    PlatformFile? avatarFile,
  }) async {
    final request = http.MultipartRequest('PUT', _uri('/api/auth/avatar'))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['isAnonymous'] = '1';

    if (displayName != null && displayName.trim().isNotEmpty) {
      request.fields['displayName'] = displayName.trim();
    }

    if (avatarFile != null) {
      request.files.add(await _multipartFile('avatarFile', avatarFile));
    }

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    final body = _decode(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_messageFrom(body, 'Cap nhat avatar khong thanh cong.'));
    }

    return AuthSession.fromProfileResponse(body, token);
  }

  Future<AdminUsersPage> getAdminUsers({
    required String token,
    String? keyword,
    String? role,
    int page = 1,
    int size = 50,
  }) async {
    final uri = _uri('/api/admin/users').replace(queryParameters: {
      'page': '$page',
      'size': '$size',
      if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
      if (role != null && role.trim().isNotEmpty) 'role': role.trim(),
    });

    final response = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_messageFrom(body, 'Khong tai duoc danh sach tai khoan.'));
    }

    return AdminUsersPage.fromJson(body);
  }

  Future<void> updateUserStatus({
    required String token,
    required String userId,
    required int isStatus,
  }) async {
    final response = await _client.put(
      _uri('/api/admin/users/$userId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'isStatus': isStatus}),
    );

    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_messageFrom(body, 'Cập nhật trạng thái người dùng thất bại.'));
    }
  }

  Future<List<AdminApplication>> getMentorApplications({
    required String token,
    String? status,
  }) async {
    final uri = _uri('/api/admin/mentor-applications').replace(queryParameters: {
      if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
    });

    final response = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_messageFrom(body, 'Không tải được danh sách đơn mentor.'));
    }

    final list = body['data'] as List<dynamic>? ?? [];
    return list.map((item) => AdminApplication.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> approveMentorApplication({
    required String token,
    required String applicationId,
    String? reason,
  }) async {
    final response = await _client.patch(
      _uri('/api/admin/mentor-applications/$applicationId/approve'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'reason': reason}),
    );

    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_messageFrom(body, 'Duyệt đơn mentor không thành công.'));
    }
  }

  Future<void> rejectMentorApplication({
    required String token,
    required String applicationId,
    required String reason,
  }) async {
    final response = await _client.patch(
      _uri('/api/admin/mentor-applications/$applicationId/reject'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'reason': reason}),
    );

    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_messageFrom(body, 'Từ chối đơn mentor không thành công.'));
    }
  }

  Future<List<AdminApplication>> getCreatorUpgradeRequests({
    required String token,
    String? status,
  }) async {
    final uri = _uri('/api/admin/creator-upgrade-requests').replace(queryParameters: {
      if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
    });

    final response = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_messageFrom(body, 'Không tải được danh sách yêu cầu creator.'));
    }

    final list = body['data'] as List<dynamic>? ?? [];
    return list.map((item) => AdminApplication.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> approveCreatorUpgradeRequest({
    required String token,
    required String requestId,
    String? reason,
  }) async {
    final response = await _client.patch(
      _uri('/api/admin/creator-upgrade-requests/$requestId/approve'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'reason': reason}),
    );

    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_messageFrom(body, 'Duyệt yêu cầu creator không thành công.'));
    }
  }

  Future<void> rejectCreatorUpgradeRequest({
    required String token,
    required String requestId,
    required String reason,
  }) async {
    final response = await _client.patch(
      _uri('/api/admin/creator-upgrade-requests/$requestId/reject'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'reason': reason}),
    );

    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_messageFrom(body, 'Từ chối yêu cầu creator không thành công.'));
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) return {};
    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : {};
  }

  String _messageFrom(Map<String, dynamic> body, String fallback) {
    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) return message;
    final error = body['error'];
    if (error is String && error.trim().isNotEmpty) return error;
    return fallback;
  }

  Future<http.MultipartFile> _multipartFile(String fieldName, PlatformFile file) {
    if (file.bytes != null) {
      return Future.value(http.MultipartFile.fromBytes(
        fieldName,
        file.bytes!,
        filename: file.name,
      ));
    }

    if (file.path == null) {
      throw AuthApiException('Khong doc duoc file ${file.name}.');
    }

    return http.MultipartFile.fromPath(fieldName, file.path!, filename: file.name);
  }
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.roleIds,
    required this.roleNames,
    this.displayName,
    this.avatarUrl,
  });

  final String accessToken;
  final String userId;
  final String fullName;
  final String email;
  final List<String> roleIds;
  final List<String> roleNames;
  final String? displayName;
  final String? avatarUrl;

  bool get isLearner => roleIds.contains('R002') || roleNames.contains('LUCY ANONYMOUS');
  bool get isMentor => roleIds.contains('R003') || roleNames.contains('MENTOR');
  bool get isCreator => roleIds.contains('R004') || roleNames.contains('CONTENT CREATOR');
  bool get isAdmin => roleIds.contains('R001') || roleNames.contains('ADMINSTRATOR');

  factory AuthSession.fromAuthResponse(Map<String, dynamic> body) {
    final outerData = body['data'] as Map<String, dynamic>? ?? {};
    final payload = outerData['data'] as Map<String, dynamic>? ?? outerData;
    return AuthSession._fromPayload(payload);
  }

  factory AuthSession.fromProfileResponse(Map<String, dynamic> body, String token) {
    final outerData = body['data'] as Map<String, dynamic>? ?? {};
    final user = outerData['user'] as Map<String, dynamic>? ?? {};
    final roles = outerData['roles'] as List<dynamic>? ?? [];

    return AuthSession(
      accessToken: token,
      userId: '${user['userId'] ?? ''}',
      fullName: '${user['fullName'] ?? ''}',
      email: '${user['email'] ?? ''}',
      displayName: user['displayName'] as String?,
      avatarUrl: user['avatarUrl'] as String?,
      roleIds: roles.map((role) => '${(role as Map<String, dynamic>)['roleId'] ?? ''}').toList(),
      roleNames: roles.map((role) => '${(role as Map<String, dynamic>)['roleName'] ?? ''}').toList(),
    );
  }

  factory AuthSession._fromPayload(Map<String, dynamic> payload) {
    final user = payload['user'] as Map<String, dynamic>? ?? {};
    final roles = payload['roles'] as List<dynamic>? ?? [];

    return AuthSession(
      accessToken: '${payload['accessToken'] ?? ''}',
      userId: '${user['userId'] ?? ''}',
      fullName: '${user['fullName'] ?? ''}',
      email: '${user['email'] ?? ''}',
      displayName: user['displayName'] as String?,
      avatarUrl: user['avatarUrl'] as String?,
      roleIds: roles.map((role) => '${(role as Map<String, dynamic>)['roleId'] ?? ''}').toList(),
      roleNames: roles.map((role) => '${(role as Map<String, dynamic>)['roleName'] ?? ''}').toList(),
    );
  }
}

class AdminUsersPage {
  const AdminUsersPage({
    required this.users,
    required this.page,
    required this.size,
    required this.total,
  });

  final List<AdminUser> users;
  final int page;
  final int size;
  final int total;

  factory AdminUsersPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    return AdminUsersPage(
      users: data.map((item) => AdminUser.fromJson(item as Map<String, dynamic>)).toList(),
      page: json['page'] as int? ?? 1,
      size: json['size'] as int? ?? data.length,
      total: json['total'] as int? ?? data.length,
    );
  }
}

class AdminUser {
  const AdminUser({
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.isStatus,
    required this.createdAt,
    required this.roles,
    this.avatarUrl,
  });

  final String userId;
  final String fullName;
  final String phoneNumber;
  final String email;
  final int isStatus;
  final String createdAt;
  final List<RoleInfo> roles;
  final String? avatarUrl;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final roles = json['roles'] as List<dynamic>? ?? [];
    return AdminUser(
      userId: '${json['userId'] ?? ''}',
      fullName: '${json['fullName'] ?? ''}',
      phoneNumber: '${json['phoneNumber'] ?? ''}',
      email: '${json['email'] ?? ''}',
      isStatus: json['isStatus'] as int? ?? 0,
      createdAt: '${json['createdAt'] ?? ''}',
      avatarUrl: json['avatarUrl'] as String?,
      roles: roles.map((role) => RoleInfo.fromJson(role as Map<String, dynamic>)).toList(),
    );
  }
}

class RoleInfo {
  const RoleInfo({required this.roleId, required this.roleName});

  final String roleId;
  final String roleName;

  factory RoleInfo.fromJson(Map<String, dynamic> json) {
    return RoleInfo(
      roleId: '${json['roleId'] ?? ''}',
      roleName: '${json['roleName'] ?? ''}',
    );
  }
}

class AdminApplication {
  const AdminApplication({
    required this.applicationId,
    required this.userId,
    required this.type,
    required this.status,
    this.rejectReason,
    required this.submittedAt,
  });

  final String applicationId;
  final String userId;
  final String type;
  final String status;
  final String? rejectReason;
  final String submittedAt;

  factory AdminApplication.fromJson(Map<String, dynamic> json) {
    return AdminApplication(
      applicationId: '${json['applicationId'] ?? ''}',
      userId: '${json['userId'] ?? ''}',
      type: '${json['type'] ?? ''}',
      status: '${json['status'] ?? ''}',
      rejectReason: json['rejectReason'] as String?,
      submittedAt: '${json['submittedAt'] ?? ''}',
    );
  }
}

class AuthApiException implements Exception {
  const AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
