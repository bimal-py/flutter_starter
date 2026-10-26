import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/domain/entity/entity.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/utils/constants/constants.dart';

/// The catalogue of sibling apps promoted through house ads. Each entry links a
/// bundled logo ([SelfPromotionAssets]) to the app's
/// `bimalkhatri.com.np/<app>/share` download page. A host app can exclude
/// itself by filtering [all] on `id`.
class SelfPromotionApps {
  SelfPromotionApps._();

  static const SelfPromotionApp callbreak = SelfPromotionApp(
    id: 'callbreak',
    name: 'Callbreak Tracker',
    tagline: 'Effortless Callbreak scorekeeping.',
    logoAsset: SelfPromotionAssets.callbreak,
    shareUrl: 'https://bimalkhatri.com.np/callbreak-score-tracker/share',
    colorValue: 0xFF407749,
  );

  static const SelfPromotionApp morselab = SelfPromotionApp(
    id: 'morselab',
    name: 'MorseLab',
    tagline: 'Learn, translate & decode Morse code.',
    logoAsset: SelfPromotionAssets.morselab,
    shareUrl: 'https://bimalkhatri.com.np/morselab/share',
    colorValue: 0xFF43978A,
  );

  static const SelfPromotionApp triad = SelfPromotionApp(
    id: 'triad',
    name: 'Triad',
    tagline: 'Notes, reminders & water tracking in one.',
    logoAsset: SelfPromotionAssets.triad,
    shareUrl: 'https://bimalkhatri.com.np/triad/share',
    colorValue: 0xFF2563EB,
  );

  static const SelfPromotionApp sudoku = SelfPromotionApp(
    id: 'sudoku',
    name: 'Sudoku Master',
    tagline: 'Scan & play the classic 9×9 puzzle.',
    logoAsset: SelfPromotionAssets.sudoku,
    shareUrl: 'https://bimalkhatri.com.np/sudoku/share',
    colorValue: 0xFF325BAD,
  );

  static const SelfPromotionApp pomodoro = SelfPromotionApp(
    id: 'pomodoro',
    name: 'Clean Pomodoro',
    tagline: 'Focus in 25-minute sprints with calming sounds.',
    logoAsset: SelfPromotionAssets.pomodoro,
    shareUrl: 'https://bimalkhatri.com.np/pomodoro/share',
    colorValue: 0xFF1B3A6B,
  );

  /// Every promotable app. The host app should exclude its own id.
  static const List<SelfPromotionApp> all = [
    callbreak,
    morselab,
    triad,
    sudoku,
    pomodoro,
  ];
}
