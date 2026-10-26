import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/domain/domain.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/utils/utils.dart';

/// The apps promoted through house ads, each with a bundled logo
/// ([SelfPromotionAssets]) and its `bimalkhatri.com.np/<app>/share` download
/// page. Replace them with your own apps.
class SelfPromotionApps {
  SelfPromotionApps._();

  static const SelfPromotionAppEntity callbreak = SelfPromotionAppEntity(
    id: 'callbreak',
    name: 'Callbreak Tracker',
    tagline: 'Effortless Callbreak scorekeeping.',
    logoAsset: SelfPromotionAssets.callbreak,
    shareUrl: 'https://bimalkhatri.com.np/callbreak-score-tracker/share',
    colorValue: 0xFF407749,
  );

  static const SelfPromotionAppEntity morselab = SelfPromotionAppEntity(
    id: 'morselab',
    name: 'MorseLab',
    tagline: 'Learn, translate & decode Morse code.',
    logoAsset: SelfPromotionAssets.morselab,
    shareUrl: 'https://bimalkhatri.com.np/morselab/share',
    colorValue: 0xFF43978A,
  );

  static const SelfPromotionAppEntity triad = SelfPromotionAppEntity(
    id: 'triad',
    name: 'Triad',
    tagline: 'Notes, reminders & water tracking in one.',
    logoAsset: SelfPromotionAssets.triad,
    shareUrl: 'https://bimalkhatri.com.np/triad/share',
    colorValue: 0xFF2563EB,
  );

  static const SelfPromotionAppEntity sudoku = SelfPromotionAppEntity(
    id: 'sudoku',
    name: 'Sudoku Master',
    tagline: 'Scan & play the classic 9×9 puzzle.',
    logoAsset: SelfPromotionAssets.sudoku,
    shareUrl: 'https://bimalkhatri.com.np/sudoku/share',
    colorValue: 0xFF325BAD,
  );

  static const SelfPromotionAppEntity pomodoro = SelfPromotionAppEntity(
    id: 'pomodoro',
    name: 'Clean Pomodoro',
    tagline: 'Focus in 25-minute sprints with calming sounds.',
    logoAsset: SelfPromotionAssets.pomodoro,
    shareUrl: 'https://bimalkhatri.com.np/pomodoro/share',
    colorValue: 0xFF1B3A6B,
  );

  /// Every promotable app. An app promoting its siblings filters out its own
  /// `id`.
  static const List<SelfPromotionAppEntity> all = [
    callbreak,
    morselab,
    triad,
    sudoku,
    pomodoro,
  ];
}
