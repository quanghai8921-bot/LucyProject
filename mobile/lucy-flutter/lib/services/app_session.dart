import 'package:lucy_app/services/auth_api.dart';

class AppSession {
  static AuthSession? current;

  static void set(AuthSession session) {
    current = session;
  }

  static void clear() {
    current = null;
  }
}
