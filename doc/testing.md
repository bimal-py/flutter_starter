# Testing

`flutter test` runs everything in `test/`, which mirrors `lib/`. The samples show one way to test each kind of code; copy the closest one when you add a feature.

| Test | Shows how to test |
|---|---|
| `test/app/screens_smoke_test.dart` | Every main screen built with the real theme and DI on a phone-sized window: layout crashes, overflows, screens that throw. A form's validation messages |
| `test/modules/auth/login_cubit_test.dart` | A cubit with fake repositories: its first state, what it sends, and that the same failure twice still reaches the listener |
| `test/modules/auth/otp_countdown_cubit_test.dart` | Timers, in fake time (`testWidgets` + `tester.pump(duration)`) |
| `test/modules/auth/auth_validators_test.dart`, `test/modules/app_upgrade/version_compare_test.dart` | Pure functions |
| `test/modules/pagination/pagination_helper_test.dart` | Paging: replace, append, de-duplicate, follow `next`, skip malformed rows |
| `test/modules/user/user_mapper_test.dart` | JSON to entity and back |
| `test/core/...` | Response envelopes, error messages, the theme cubit, the screen-size guard |

## Fakes, not mocks

The starter has no mocking package. A fake implements the repository interface, does only what the test needs, and lets everything else fail loudly:

```dart
class _FakeRemoteAuth implements RemoteAuthRepository {
  final calls = <String>[];

  @override
  Future<void> login({required String email, required String password, required bool remember}) async =>
      calls.add(email);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
```

Register the use cases the cubit reads from `getIt` with the fakes in `setUp`, and call `getIt.reset` in `tearDown`.

## Screens

The smoke test stands in for the native start-up: `.env` from a string (`dotenv.loadFromString`), Hive in a temporary folder, secure storage and package info from mock values, HydratedBloc in memory, then `configureDependencyInjection()`. Add a new screen to its `screens` map.

Platform plugins (web view, camera, ads, Firebase) don't run in `flutter test`; test the code around them, and check those screens on a device.

## The README demo

The demo GIF is made from the same test, with the app's real fonts:

```sh
CAPTURE_DIR=/tmp/screens flutter test test/app/screens_smoke_test.dart
```

That writes one PNG per screen. Frame them with [the screenshot tool](tools/screenshots.md) (`--config` listing the PNGs) and join the frames into a GIF.
