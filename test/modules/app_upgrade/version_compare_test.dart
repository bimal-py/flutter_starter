import 'package:flutter_starter/modules/app_upgrade/app_upgrade.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final helper = RemoteConfigHelper();

  test('an older version is lower, part by part', () {
    expect(helper.isVersionLower('1.2.3', '1.2.4'), isTrue);
    expect(helper.isVersionLower('1.9.9', '1.10.0'), isTrue);
    expect(helper.isVersionLower('1.2', '1.2.1'), isTrue);
  });

  test('the same or a newer version is not', () {
    expect(helper.isVersionLower('1.2.0', '1.2'), isFalse);
    expect(helper.isVersionLower('1.10.0', '1.9.9'), isFalse);
    expect(helper.isVersionLower('2.0.0', '1.9'), isFalse);
  });

  test('a malformed version never asks for an update', () {
    expect(helper.isVersionLower('1.x', '2.0.0'), isFalse);
    expect(helper.isVersionLower('1.0.0', ''), isFalse);
  });
}
