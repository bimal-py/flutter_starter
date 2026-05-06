import 'package:flutter/foundation.dart';

import '../helpers/env_helper.dart';

/// Single source of truth for everything loaded from `.env`.
///
/// Group entries by section (API, OAuth, third-party, feature flags). Add
/// getters here rather than scattering `EnvHelper.get('...')` calls across
/// the codebase — that way there's one place to audit which keys the app
/// reads, and consumers don't have to remember the string key.
///
/// Use **getters** (not `static const` / `static final`) so values reflect
/// the current `.env` after hot reload.
class EnvConfig {
  EnvConfig._();

  // ── API ──────────────────────────────────────────────────────────
  static String get apiBaseUrl => EnvHelper.get('API_BASE_URL');

  /// Picks DEV vs PROD auth key based on build mode. Define both in `.env`.
  /// (Treat as obfuscation, not a secret — anything in the binary is
  /// extractable. Real secrets must live behind your backend.)
  static String get authKey => kReleaseMode
      ? EnvHelper.get('PROD_AUTH_KEY')
      : EnvHelper.get('DEV_AUTH_KEY');

  // ── OAuth providers ──────────────────────────────────────────────
  static String get appleClientId => EnvHelper.get('APPLE_CLIENT_ID');
  static String get appleRedirectUrl => EnvHelper.get('APPLE_REDIRECT_URL');
  static String get googleServerClientId =>
      EnvHelper.get('GOOGLE_SERVER_CLIENT_ID');

  // ── Feature flags ────────────────────────────────────────────────
  static bool get firebaseEnabled => EnvHelper.getBool('FIREBASE_ENABLED');
}

/// API endpoint paths. Combine with [EnvConfig.apiBaseUrl]:
/// `'${EnvConfig.apiBaseUrl}${ApiEndpoints.login}'`.
///
/// Add nested classes per feature as the API grows:
/// ```dart
/// class AuthEndpoints {
///   AuthEndpoints._();
///   static const String login = '/auth/login';
///   static const String refresh = '/auth/refresh';
/// }
/// ```
class ApiEndpoints {
  ApiEndpoints._();
  // Add paths here as you build features.
}
