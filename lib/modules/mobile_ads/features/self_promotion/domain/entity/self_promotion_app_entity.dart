import 'package:equatable/equatable.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/utils/utils.dart';

/// An app promoted through a house ad. Static config with no backend, so the
/// fields are non-nullable.
class SelfPromotionAppEntity extends Equatable {
  const SelfPromotionAppEntity({
    required this.id,
    required this.name,
    required this.tagline,
    required this.logoAsset,
    required this.shareUrl,
    required this.colorValue,
    this.cta = SelfPromotionStrings.install,
  });

  final String id;
  final String name;
  final String tagline;
  final String logoAsset;
  final String shareUrl;

  /// Brand colour as ARGB, so the entity stays Flutter-free. Keep it dark:
  /// the house ads draw white text on it.
  final int colorValue;
  final String cta;

  @override
  List<Object?> get props => [
    id,
    name,
    tagline,
    logoAsset,
    shareUrl,
    colorValue,
    cta,
  ];
}
