/// The signed-in person's own Hive box.
class AuthUserStorageKeys {
  AuthUserStorageKeys._();

  static const String boxName = 'auth_user_box';

  /// `users/me/` → `user`.
  static const String user = 'user';
}
