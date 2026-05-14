import 'package:equatable/equatable.dart';

/// Backend-agnostic user shape. Anything app-specific (roles, claims, etc.)
/// goes in [extras] so the contract stays stable across REST / Firebase /
/// Supabase / custom JWT implementations.
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.extras = const {},
  });

  /// Opaque, provider-stable identifier. Don't assume it's numeric.
  final String id;

  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  /// Backend-specific payload. Must be JSON-serialisable for round-trip.
  final Map<String, dynamic> extras;

  AuthUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    Map<String, dynamic>? extras,
  }) => AuthUser(
    id: id ?? this.id,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    photoUrl: photoUrl ?? this.photoUrl,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    extras: extras ?? this.extras,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    if (email != null) 'email': email,
    if (displayName != null) 'displayName': displayName,
    if (photoUrl != null) 'photoUrl': photoUrl,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    'isEmailVerified': isEmailVerified,
    'isPhoneVerified': isPhoneVerified,
    if (extras.isNotEmpty) 'extras': extras,
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'].toString(),
    email: json['email'] as String?,
    displayName: json['displayName'] as String?,
    photoUrl: json['photoUrl'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
    extras: (json['extras'] as Map?)?.cast<String, dynamic>() ?? const {},
  );

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    phoneNumber,
    isEmailVerified,
    isPhoneVerified,
    extras,
  ];
}
