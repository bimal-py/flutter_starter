part of 'theme_cubit.dart';

class ThemeState extends Equatable {
  const ThemeState({
    this.variant = ThemeVariant.system,
    required this.developerSource,
    this.userOverride,
  });

  final ThemeVariant variant;
  final ThemeSource developerSource;
  final ThemeSource? userOverride;

  /// The source that actually drives AppThemeBuilder.compose. UserOverride
  /// wins when set; otherwise falls back to the developer's wired source.
  ThemeSource get effectiveSource => userOverride ?? developerSource;

  /// True when the end user has applied a playground override.
  bool get hasUserOverride => userOverride != null;

  ThemeState copyWith({
    ThemeVariant? variant,
    ThemeSource? developerSource,
    ThemeSource? userOverride,
  }) =>
      ThemeState(
        variant: variant ?? this.variant,
        developerSource: developerSource ?? this.developerSource,
        userOverride: userOverride ?? this.userOverride,
      );

  ThemeState clearUserOverride() => ThemeState(
        variant: variant,
        developerSource: developerSource,
      );

  Map<String, dynamic> toJson() => {
        'variant': variant.id,
        'developerSource': developerSource.toJson(),
        if (userOverride != null) 'userOverride': userOverride!.toJson(),
      };

  factory ThemeState.fromJson(Map<String, dynamic> json) => ThemeState(
        variant: ThemeVariant.fromId(json['variant'] as String?),
        developerSource:
            themeSourceFromJson(json['developerSource'] as Map<String, dynamic>?),
        userOverride: json['userOverride'] is Map<String, dynamic>
            ? themeSourceFromJson(json['userOverride'] as Map<String, dynamic>)
            : null,
      );

  @override
  List<Object?> get props => [variant, developerSource, userOverride];
}
