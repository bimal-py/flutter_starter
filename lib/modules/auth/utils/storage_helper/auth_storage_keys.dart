class AuthStorageKeys {
  AuthStorageKeys._();

  static const String boxName = 'auth_box';

  // Hive box entries.
  static const String sessionKey = '${boxName}_session';

  /// Login email kept while "Remember me" is on; survives logout.
  static const String rememberedEmailKey = '${boxName}_remembered_email';

  // Secure-storage entries, namespaced under the box name.
  static const String accessTokenKey = '${boxName}_access_token';
  static const String refreshTokenKey = '${boxName}_refresh_token';
}
