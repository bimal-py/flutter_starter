extension StringExtension on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// The app's one email rule: `name+tag@sub.domain.tld`, any TLD length.
  bool get isValidEmail => _email.hasMatch(this);
}

final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

extension NullableStringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// People's names as shown in the app: each word starts with a capital
  /// ("ada lovelace" → "Ada Lovelace"); the rest is kept as typed.
  String? get capitalizeWords => this
      ?.split(' ')
      .map((word) => word.isEmpty ? word : word.capitalize)
      .join(' ');
  String orDefault([String fallback = '']) =>
      this == null || this!.isEmpty ? fallback : this!;
}
