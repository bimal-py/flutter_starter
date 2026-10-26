import 'package:equatable/equatable.dart';

enum ThirdPartyProvider { google, apple }

/// What the platform SDK hands back; the backend redeems it for our tokens.
class ThirdPartyCredential extends Equatable {
  const ThirdPartyCredential({
    required this.provider,
    required this.token,
    this.isFromIos = false,
    this.fullName,
    this.redirectUri,
  });

  final ThirdPartyProvider provider;

  // Google: ID token. Apple: single-use authorization code.
  final String token;

  // Apple only: iOS signs in with the bundle ID, Android with the Services ID.
  final bool isFromIos;

  // Apple only: shared on the first sign-in and never again.
  final String? fullName;

  // Apple on Android: the return URL the browser flow used.
  final String? redirectUri;

  @override
  List<Object?> get props => [
    provider,
    token,
    isFromIos,
    fullName,
    redirectUri,
  ];
}
