import 'package:flutter_starter/modules/user/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const json = {
    'id': 7,
    'full_name': 'Ada Lovelace',
    'username': 'ada',
    'email': 'ada@example.com',
    'phone': null,
    'gender': 'female',
    'joined_at': '2026-01-02T03:04:05Z',
    'avatar_url': 'https://example.com/ada.png',
    'dob': '1815-12-10',
  };

  test('JSON from the backend becomes a user', () {
    final user = UserMapper.fromJsonToEntity(json);
    expect(user.id, '7');
    expect(user.fullName, 'Ada Lovelace');
    expect(user.email, 'ada@example.com');
    expect(user.phone, isNull);
    expect(user.joinedAt, DateTime.utc(2026, 1, 2, 3, 4, 5).toLocal());
    expect(user.birthday, DateTime(1815, 12, 10));
    expect(user.initials, 'AL');
  });

  test('a user goes back to the same JSON', () {
    final again = UserMapper.toJsonFromEntity(
      UserMapper.fromJsonToEntity(json),
    );
    expect(again['full_name'], 'Ada Lovelace');
    expect(again['joined_at'], '2026-01-02T03:04:05.000Z');
    expect(again['dob'], '1815-12-10');
    expect(
      UserMapper.fromJsonToEntity(again),
      UserMapper.fromJsonToEntity(json),
    );
  });
}
