// Renames the starter into your app: Dart package, Android application id,
// iOS bundle id, home-screen label and the in-app name.
//
//   dart run tool/rename_app.dart \
//     --package my_shop \
//     --bundle-id com.example.myshop \
//     --label "My Shop" \
//     --name "My Shop Inventory"
//
// Reads the current values from the project, so it also works on an app that
// was renamed before. Run it from the project root, then run
// `flutter pub get` and `dart run build_runner build`.
import 'dart:io';

void main(List<String> args) {
  final options = _parse(args);
  final package = options['package'];
  final bundleId = options['bundle-id'];
  final label = options['label'];
  final name = options['name'] ?? label;
  if (package == null || bundleId == null || label == null || name == null) {
    _fail(
      'Usage: dart run tool/rename_app.dart --package <snake_case> '
      '--bundle-id <a.b.c> --label "<home-screen name>" [--name "<full name>"]',
    );
  }
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(package)) {
    _fail('--package must be snake_case (letters, digits, underscores).');
  }
  // Android ids are Java packages: every segment starts with a letter and
  // holds letters, digits or underscores only. iOS accepts that subset too.
  final segment = RegExp(r'^[A-Za-z][A-Za-z0-9_]*$');
  final segments = bundleId.split('.');
  if (segments.length < 2 || !segments.every(segment.hasMatch)) {
    _fail('--bundle-id needs two or more dot-separated segments, '
        'each starting with a letter (e.g. com.example.myshop).');
  }

  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) _fail('Run this from the project root.');
  final oldPackage =
      RegExp(r'^name:\s*(\S+)', multiLine: true)
          .firstMatch(pubspec.readAsStringSync())
          ?.group(1) ??
      _fail('No `name:` in pubspec.yaml.');

  final gradle = File('android/app/build.gradle.kts');
  final oldAndroidId =
      RegExp(r'applicationId\s*=\s*"([^"]+)"')
          .firstMatch(gradle.readAsStringSync())
          ?.group(1) ??
      _fail('No applicationId in android/app/build.gradle.kts.');

  // 1. Dart package name and every package import.
  _replaceIn(pubspec, RegExp(r'^name:\s*\S+', multiLine: true), 'name: $package');
  for (final dir in ['lib', 'test', 'integration_test', 'tool']) {
    final root = Directory(dir);
    if (!root.existsSync()) continue;
    for (final file in root.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      _replaceText(file, 'package:$oldPackage/', 'package:$package/');
    }
  }

  // 2. Android: namespace, application id, MainActivity package and folder.
  _replaceIn(gradle, RegExp(r'namespace\s*=\s*"[^"]+"'), 'namespace = "$bundleId"');
  _replaceIn(
    gradle,
    RegExp(r'applicationId\s*=\s*"[^"]+"'),
    'applicationId = "$bundleId"',
  );
  _moveMainActivity(oldAndroidId, bundleId);
  _replaceIn(
    File('android/app/src/main/AndroidManifest.xml'),
    RegExp(r'android:label="[^"]*"'),
    'android:label="${_xml(label)}"',
  );

  // 3. iOS: bundle ids (app + tests) and the names under the icon.
  final pbxproj = File('ios/Runner.xcodeproj/project.pbxproj');
  if (pbxproj.existsSync()) {
    var text = pbxproj.readAsStringSync();
    text = text.replaceAllMapped(
      RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);'),
      (m) => m.group(1)!.trim().endsWith('.RunnerTests')
          ? 'PRODUCT_BUNDLE_IDENTIFIER = $bundleId.RunnerTests;'
          : 'PRODUCT_BUNDLE_IDENTIFIER = $bundleId;',
    );
    pbxproj.writeAsStringSync(text);
  }
  final plist = File('ios/Runner/Info.plist');
  if (plist.existsSync()) {
    _replacePlistString(plist, 'CFBundleDisplayName', _xml(label));
    _replacePlistString(plist, 'CFBundleName', package);
  }

  // 4. In-app identity and the web shell.
  final constants = File('lib/core/utils/constants/app_constants.dart');
  if (constants.existsSync()) {
    _replaceIn(
      constants,
      RegExp(r"static const String appName = '[^']*';"),
      "static const String appName = '${_dartString(name)}';",
    );
    _replaceIn(
      constants,
      RegExp(r"static const String appAndroidPackageId = '[^']*';"),
      "static const String appAndroidPackageId = '$bundleId';",
    );
  }
  final manifest = File('web/manifest.json');
  if (manifest.existsSync()) {
    _replaceIn(manifest, RegExp(r'"name":\s*"[^"]*"'), '"name": "${_json(name)}"');
    _replaceIn(
      manifest,
      RegExp(r'"short_name":\s*"[^"]*"'),
      '"short_name": "${_json(label)}"',
    );
  }
  final index = File('web/index.html');
  if (index.existsSync()) {
    _replaceIn(index, RegExp(r'<title>[^<]*</title>'), '<title>${_xml(name)}</title>');
    _replaceIn(
      index,
      RegExp(r'name="apple-mobile-web-app-title" content="[^"]*"'),
      'name="apple-mobile-web-app-title" content="${_xml(label)}"',
    );
  }

  stdout.writeln('''
Renamed $oldPackage -> $package
  bundle id : $bundleId (Android and iOS)
  label     : $label (under the app icon)
  name      : $name (AppConstants.appName)

Next:
  flutter pub get
  dart run build_runner build
  flutter analyze
If the app uses Firebase, run `flutterfire configure` again for the new ids.''');
}

Map<String, String> _parse(List<String> args) {
  final out = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (!arg.startsWith('--')) continue;
    final eq = arg.indexOf('=');
    if (eq != -1) {
      out[arg.substring(2, eq)] = arg.substring(eq + 1);
    } else if (i + 1 < args.length) {
      out[arg.substring(2)] = args[++i];
    }
  }
  return out;
}

void _moveMainActivity(String oldId, String newId) {
  final base = 'android/app/src/main/kotlin';
  final oldDir = Directory('$base/${oldId.replaceAll('.', '/')}');
  final source = File('${oldDir.path}/MainActivity.kt');
  if (!source.existsSync()) {
    stderr.writeln('MainActivity.kt not found under ${oldDir.path}: skipped.');
    return;
  }
  final text = source
      .readAsStringSync()
      .replaceFirst(RegExp(r'^package\s+\S+', multiLine: true), 'package $newId');
  final newDir = Directory('$base/${newId.replaceAll('.', '/')}')
    ..createSync(recursive: true);
  source.deleteSync();
  File('${newDir.path}/MainActivity.kt').writeAsStringSync(text);
  // Drop the folders the old id leaves empty.
  var dir = oldDir;
  while (dir.path != base &&
      dir.existsSync() &&
      dir.listSync().isEmpty) {
    dir.deleteSync();
    dir = dir.parent;
  }
}

void _replacePlistString(File plist, String key, String value) => _replaceIn(
  plist,
  RegExp('(<key>$key</key>\\s*<string>)[^<]*(</string>)'),
  null,
  (m) => '${m.group(1)}$value${m.group(2)}',
);

void _replaceIn(
  File file,
  Pattern pattern,
  String? replacement, [
  String Function(Match)? mapper,
]) {
  if (!file.existsSync()) return;
  final text = file.readAsStringSync();
  final updated = mapper != null
      ? text.replaceAllMapped(pattern, mapper)
      : text.replaceAll(pattern, replacement!);
  if (updated != text) file.writeAsStringSync(updated);
}

void _replaceText(File file, String from, String to) {
  final text = file.readAsStringSync();
  if (text.contains(from)) file.writeAsStringSync(text.replaceAll(from, to));
}

String _xml(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _json(String s) => s.replaceAll(r'\', r'\\').replaceAll('"', r'\"');

String _dartString(String s) => s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

Never _fail(String message) {
  stderr.writeln(message);
  exit(64);
}
