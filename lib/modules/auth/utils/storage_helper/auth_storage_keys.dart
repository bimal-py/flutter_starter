class AuthStorageKeys {
  AuthStorageKeys._();

  /// JSON-encoded [AuthUser] in the shared Hive `app_box`.
  static const String loggedInUserKey = 'auth.logged_in_user';

  /// `flutter_secure_storage`.
  static const String accessTokenKey = 'auth.access_token';
  static const String refreshTokenKey = 'auth.refresh_token';
}
