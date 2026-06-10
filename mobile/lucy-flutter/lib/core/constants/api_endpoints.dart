class ApiEndpoints {
  static const String authBaseUrl = String.fromEnvironment(
    'AUTH_BASE_URL',
    defaultValue: 'https://lucy-auth-production.up.railway.app',
  );

  static const String paymentBaseUrl = String.fromEnvironment(
    'PAYMENT_BASE_URL',
    defaultValue: 'https://lucyproject-production.up.railway.app',
  );

  static const String contentBaseUrl = String.fromEnvironment(
    'CONTENT_BASE_URL',
    defaultValue: 'https://stunning-passion-production-aee9.up.railway.app',
  );

  static const String realtimeBaseUrl = String.fromEnvironment(
    'REALTIME_BASE_URL',
    defaultValue: 'https://adorable-success-production-64f4.up.railway.app/',
  );

  static String get register => '$authBaseUrl/api/auth/register';
  static String get login => '$authBaseUrl/api/auth/login';

  static String get topUp => '$paymentBaseUrl/api/topup';
  static String get withdraw => '$paymentBaseUrl/api/withdraw';
  static String get donate => '$paymentBaseUrl/api/donate';

  static String get levels => '$contentBaseUrl/api/levels';
  static String get rooms => '$contentBaseUrl/api/rooms';

  static String get realtimeSocket => realtimeBaseUrl;
}
