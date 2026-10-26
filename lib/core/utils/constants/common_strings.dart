/// Copy shared by the app shell, core helpers and the common widgets:
/// anything with no feature of its own to belong to. Feature copy lives in
/// the feature's `utils/constants/<feature>_strings.dart`.
class CommonStrings {
  CommonStrings._();

  static const String loading = 'Loading...';
  static const String goBack = 'Go back';
  static const String cancel = 'Cancel';
  static const String done = 'Done';
}
