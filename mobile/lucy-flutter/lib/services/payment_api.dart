import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lucy_app/services/app_session.dart';

class PaymentApi {
  PaymentApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ??
            const String.fromEnvironment(
              'LUCY_PAYMENT_API_URL',
              defaultValue: 'http://localhost:5199',
            );

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers() {
    final userId = AppSession.current?.userId ?? '';
    return {
      'Content-Type': 'application/json',
      if (userId.isNotEmpty) 'X-User-Id': userId,
    };
  }

  Map<String, String> _authHeaders() {
    final userId = AppSession.current?.userId ?? '';
    return {
      if (userId.isNotEmpty) 'X-User-Id': userId,
    };
  }

  Future<PaymentWallet> getWallet() async {
    final response = await _client.get(_uri('/api/payment/wallet'), headers: _headers());
    return PaymentWallet.fromJson(_successMap(response, 'Khong tai duoc vi.'));
  }

  Future<List<PaymentTransaction>> getTransactions() async {
    final response = await _client.get(_uri('/api/payment/transactions'), headers: _headers());
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PaymentApiException(_messageFrom(body, 'Khong tai duoc giao dich.'));
    }
    final data = body is List<dynamic> ? body : body['data'] as List<dynamic>? ?? [];
    return data.map((item) => PaymentTransaction.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<TopUpOrder> depositVnd(num amount, {String provider = 'MOMO'}) async {
    final response = await _client.post(
      _uri('/api/payment/deposit'),
      headers: _headers(),
      body: jsonEncode({'amount': amount, 'paymentProvider': provider}),
    );
    return TopUpOrder.fromJson(_successMap(response, 'Nap tien that bai.'));
  }

  Future<PaymentSetting?> getMomoSetting() async {
    final response = await _client.get(_uri('/api/payment/admin/settings/momo'), headers: _headers());
    final body = _decode(response);
    if (response.statusCode == 204 || body == null) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PaymentApiException(_messageFrom(body, 'Khong tai duoc cau hinh MoMo.'));
    }
    if (body is Map<String, dynamic> && body.isEmpty) return null;
    return PaymentSetting.fromJson(Map<String, dynamic>.from(body as Map));
  }

  Future<PaymentSetting> saveMomoSetting({
    required String receiverName,
    required String receiverPhone,
    String? qrImageUrl,
    String? transferContentTemplate,
    int isActive = 1,
  }) async {
    final response = await _client.post(
      _uri('/api/payment/admin/settings/momo'),
      headers: _headers(),
      body: jsonEncode({
        'receiverName': receiverName,
        'receiverPhone': receiverPhone,
        'qrImageUrl': qrImageUrl,
        'transferContentTemplate': transferContentTemplate,
        'isActive': isActive,
      }),
    );
    return PaymentSetting.fromJson(_successMap(response, 'Khong luu duoc cau hinh MoMo.'));
  }

  Future<PaymentSetting> uploadMomoQr(PlatformFile file) async {
    final request = http.MultipartRequest('POST', _uri('/api/payment/admin/settings/momo/qr'))
      ..headers.addAll(_authHeaders());
    if (file.bytes != null) {
      request.files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name));
    } else if (file.path != null) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path!, filename: file.name));
    } else {
      throw PaymentApiException('File QR khong co du lieu.');
    }
    final response = await http.Response.fromStream(await _client.send(request));
    return PaymentSetting.fromJson(_successMap(response, 'Khong upload duoc anh QR MoMo.'));
  }

  Future<List<TopUpOrder>> getAdminTopUpOrders({String status = 'PENDING'}) async {
    final uri = _uri('/api/payment/admin/topup-orders').replace(queryParameters: {'status': status});
    final response = await _client.get(uri, headers: _headers());
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PaymentApiException(_messageFrom(body, 'Khong tai duoc don nap tien.'));
    }
    final data = body is List<dynamic> ? body : body['data'] as List<dynamic>? ?? [];
    return data.map((item) => TopUpOrder.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<TopUpOrder> approveTopUpOrder(String orderId) async {
    final response = await _client.post(
      _uri('/api/payment/admin/topup-orders/$orderId/approve'),
      headers: _headers(),
    );
    return TopUpOrder.fromJson(_successMap(response, 'Khong duyet duoc don nap tien.'));
  }

  Future<TopUpOrder> rejectTopUpOrder(String orderId, {String? reason}) async {
    final response = await _client.post(
      _uri('/api/payment/admin/topup-orders/$orderId/reject'),
      headers: _headers(),
      body: jsonEncode({'reason': reason}),
    );
    return TopUpOrder.fromJson(_successMap(response, 'Khong tu choi duoc don nap tien.'));
  }

  Future<List<WithdrawRequestInfo>> getAdminWithdrawRequests({String status = 'PENDING'}) async {
    final uri = _uri('/api/payment/admin/withdraw-requests').replace(queryParameters: {'status': status});
    final response = await _client.get(uri, headers: _headers());
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PaymentApiException(_messageFrom(body, 'Khong tai duoc yeu cau rut tien.'));
    }
    final data = body is List<dynamic> ? body : body['data'] as List<dynamic>? ?? [];
    return data.map((item) => WithdrawRequestInfo.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<WithdrawRequestInfo> approveWithdrawRequest(String requestId) async {
    final response = await _client.post(
      _uri('/api/payment/admin/withdraw/approve/$requestId'),
      headers: _headers(),
    );
    return WithdrawRequestInfo.fromJson(_successMap(response, 'Khong duyet duoc yeu cau rut tien.'));
  }

  Future<WithdrawRequestInfo> rejectWithdrawRequest(String requestId, {String? reason}) async {
    final response = await _client.post(
      _uri('/api/payment/admin/withdraw/reject/$requestId'),
      headers: _headers(),
      body: jsonEncode({'rejectReason': reason}),
    );
    return WithdrawRequestInfo.fromJson(_successMap(response, 'Khong tu choi duoc yeu cau rut tien.'));
  }

  Future<void> purchaseContent(String contentId) async {
    final response = await _client.post(
      _uri('/api/payment/purchase/content'),
      headers: _headers(),
      body: jsonEncode({'contentId': contentId}),
    );
    _successMap(response, 'Mua video that bai.');
  }

  Future<void> purchaseLive(String roomId) async {
    final response = await _client.post(
      _uri('/api/payment/purchase/live'),
      headers: _headers(),
      body: jsonEncode({'roomId': roomId}),
    );
    _successMap(response, 'Mua ve live that bai.');
  }

  Future<void> donate({
    required String toUserId,
    required num amount,
    String? roomId,
    String? messageText,
    String? giftImageUrl,
    String? giftId,
    int? quantity,
  }) async {
    final response = await _client.post(
      _uri('/api/payment/donate'),
      headers: _headers(),
      body: jsonEncode({
        'toUserId': toUserId,
        'amount': amount,
        if (roomId != null) 'roomId': roomId,
        if (messageText != null) 'messageText': messageText,
        if (giftImageUrl != null) 'giftImageUrl': giftImageUrl,
        if (giftId != null) 'giftId': giftId,
        if (quantity != null) 'quantity': quantity,
      }),
    );
    _successMap(response, 'Donate that bai.');
  }

  Future<void> withdraw({
    required num amount,
    required String bankName,
    required String bankAccountNumber,
    required String bankAccountName,
  }) async {
    final response = await _client.post(
      _uri('/api/payment/withdraw'),
      headers: _headers(),
      body: jsonEncode({
        'amount': amount,
        'bankName': bankName,
        'bankAccountNumber': bankAccountNumber,
        'bankAccountName': bankAccountName,
      }),
    );
    _successMap(response, 'Tao yeu cau rut tien that bai.');
  }

  Future<List<PaymentGift>> getGifts() async {
    final response = await _client.get(_uri('/api/payment/gifts'), headers: _headers());
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PaymentApiException(_messageFrom(body, 'Khong tai duoc danh sach qua tang.'));
    }
    final data = body is List<dynamic> ? body : body['data'] as List<dynamic>? ?? [];
    return data.map((item) => PaymentGift.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Map<String, dynamic> _successMap(http.Response response, String fallback) {
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PaymentApiException(_messageFrom(body, fallback));
    }
    return body is Map<String, dynamic> ? body : <String, dynamic>{};
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  String _messageFrom(dynamic body, String fallback) {
    if (body is Map<String, dynamic>) {
      return '${body['message'] ?? body['Message'] ?? body['error'] ?? fallback}';
    }
    return fallback;
  }
}

class PaymentWallet {
  const PaymentWallet({
    required this.walletId,
    required this.userId,
    required this.balance,
    required this.currencyCode,
  });

  final String walletId;
  final String userId;
  final num balance;
  final String currencyCode;

  factory PaymentWallet.fromJson(Map<String, dynamic> json) {
    return PaymentWallet(
      walletId: '${json['walletId'] ?? ''}',
      userId: '${json['userId'] ?? ''}',
      balance: _numOrZero(json['balance']),
      currencyCode: '${json['currencyCode'] ?? 'XU'}',
    );
  }
}

class PaymentTransaction {
  const PaymentTransaction({
    required this.id,
    required this.type,
    required this.direction,
    required this.amount,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String type;
  final String direction;
  final num amount;
  final String status;
  final String? createdAt;

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: '${json['walletTransactionId'] ?? ''}',
      type: '${json['transactionType'] ?? ''}',
      direction: '${json['direction'] ?? ''}',
      amount: _numOrZero(json['amount']),
      status: '${json['transactionStatus'] ?? ''}',
      createdAt: json['createdAt'] as String?,
    );
  }
}

class TopUpOrder {
  const TopUpOrder({
    required this.topUpOrderId,
    required this.userId,
    required this.amount,
    required this.coins,
    required this.orderStatus,
    this.paymentProvider,
    this.receiverName,
    this.receiverPhone,
    this.qrImageUrl,
    this.transferContent,
    this.createdAt,
    this.paidAt,
  });

  final String topUpOrderId;
  final String userId;
  final num amount;
  final num coins;
  final String orderStatus;
  final String? paymentProvider;
  final String? receiverName;
  final String? receiverPhone;
  final String? qrImageUrl;
  final String? transferContent;
  final String? createdAt;
  final String? paidAt;

  factory TopUpOrder.fromJson(Map<String, dynamic> json) {
    return TopUpOrder(
      topUpOrderId: '${json['topUpOrderId'] ?? ''}',
      userId: '${json['userId'] ?? ''}',
      amount: _numOrZero(json['amount']),
      coins: _numOrZero(json['coins']),
      orderStatus: '${json['orderStatus'] ?? ''}',
      paymentProvider: json['paymentProvider'] as String?,
      receiverName: json['receiverName'] as String?,
      receiverPhone: json['receiverPhone'] as String?,
      qrImageUrl: json['qrImageUrl'] as String?,
      transferContent: json['transferContent'] as String?,
      createdAt: json['createdAt'] as String?,
      paidAt: json['paidAt'] as String?,
    );
  }
}

class WithdrawRequestInfo {
  const WithdrawRequestInfo({
    required this.withdrawRequestId,
    required this.userId,
    required this.walletId,
    required this.amount,
    required this.feePercent,
    required this.feeAmount,
    required this.netAmount,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankAccountName,
    required this.requestStatus,
    this.rejectReason,
    this.requestedAt,
    this.reviewedAt,
  });

  final String withdrawRequestId;
  final String userId;
  final String walletId;
  final num amount;
  final num feePercent;
  final num feeAmount;
  final num netAmount;
  final String bankName;
  final String bankAccountNumber;
  final String bankAccountName;
  final String requestStatus;
  final String? rejectReason;
  final String? requestedAt;
  final String? reviewedAt;

  factory WithdrawRequestInfo.fromJson(Map<String, dynamic> json) {
    return WithdrawRequestInfo(
      withdrawRequestId: '${json['withdrawRequestId'] ?? ''}',
      userId: '${json['userId'] ?? ''}',
      walletId: '${json['walletId'] ?? ''}',
      amount: _numOrZero(json['amount']),
      feePercent: _numOrZero(json['feePercent']),
      feeAmount: _numOrZero(json['feeAmount']),
      netAmount: _numOrZero(json['netAmount']),
      bankName: '${json['bankName'] ?? ''}',
      bankAccountNumber: '${json['bankAccountNumber'] ?? ''}',
      bankAccountName: '${json['bankAccountName'] ?? ''}',
      requestStatus: '${json['requestStatus'] ?? ''}',
      rejectReason: json['rejectReason'] as String?,
      requestedAt: json['requestedAt'] as String?,
      reviewedAt: json['reviewedAt'] as String?,
    );
  }
}

class PaymentSetting {
  const PaymentSetting({
    required this.paymentSettingId,
    required this.providerCode,
    required this.receiverUserId,
    required this.receiverName,
    required this.receiverPhone,
    this.qrImageUrl,
    this.transferContentTemplate,
    this.isActive = 1,
  });

  final String paymentSettingId;
  final String providerCode;
  final String receiverUserId;
  final String receiverName;
  final String receiverPhone;
  final String? qrImageUrl;
  final String? transferContentTemplate;
  final int isActive;

  factory PaymentSetting.fromJson(Map<String, dynamic> json) {
    return PaymentSetting(
      paymentSettingId: '${json['paymentSettingId'] ?? ''}',
      providerCode: '${json['providerCode'] ?? ''}',
      receiverUserId: '${json['receiverUserId'] ?? ''}',
      receiverName: '${json['receiverName'] ?? ''}',
      receiverPhone: '${json['receiverPhone'] ?? ''}',
      qrImageUrl: json['qrImageUrl'] as String?,
      transferContentTemplate: json['transferContentTemplate'] as String?,
      isActive: (json['isActive'] is num) ? (json['isActive'] as num).toInt() : int.tryParse('${json['isActive'] ?? 1}') ?? 1,
    );
  }
}

num _numOrZero(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}

class PaymentGift {
  const PaymentGift({
    required this.giftId,
    required this.giftName,
    required this.priceAmount,
    this.giftImageUrl,
  });

  final String giftId;
  final String giftName;
  final num priceAmount;
  final String? giftImageUrl;

  factory PaymentGift.fromJson(Map<String, dynamic> json) {
    return PaymentGift(
      giftId: '${json['giftId'] ?? ''}',
      giftName: '${json['giftName'] ?? ''}',
      priceAmount: _numOrZero(json['priceAmount']),
      giftImageUrl: (json['iconUrl'] ?? json['giftImageUrl']) as String?,
    );
  }
}

class PaymentApiException implements Exception {
  PaymentApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
