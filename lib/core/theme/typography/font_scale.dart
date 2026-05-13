/// Per-language font-size multipliers. Some scripts (Devanagari, Bengali,
/// Arabic) render visually smaller than Latin at the same `fontSize` because
/// of x-height / cap-height differences.
class AppTextScale {
  AppTextScale._();

  static const Map<String, double> _scales = {
    // 'ne': 1.10,  // Nepali / Devanagari
    // 'bn': 1.10,  // Bengali
    // 'ar': 1.05,  // Arabic
  };

  static double of(String? languageCode) {
    if (languageCode == null) return 1.0;
    return _scales[languageCode] ?? 1.0;
  }
}
