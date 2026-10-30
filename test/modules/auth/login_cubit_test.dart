import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hand-written fakes: implement only what the cubit uses; anything else
/// fails loudly through noSuchMethod.
class _FakeRemoteAuth implements RemoteAuthRepository {
  final calls = <({String email, String password, bool remember})>[];
  Object? error;

  @override
  Future<void> login({
    required String email,
    required String password,
    required bool remember,
  }) async {
    calls.add((email: email, password: password, remember: remember));
    if (error case final error?) throw error;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSession implements LocalAuthSessionRepository {
  _FakeSession(this.email);

  final String? email;

  @override
  String? rememberedEmail() => email;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeRemoteAuth remote;

  setUp(() {
    remote = _FakeRemoteAuth();
    getIt
      ..registerFactory(
        () => GetRememberedEmailUseCase(_FakeSession('ada@example.com')),
      )
      ..registerFactory(() => LoginUseCase(remote));
  });
  tearDown(getIt.reset);

  test('starts with Remember me on and the remembered email', () {
    final cubit = LoginCubit();
    expect(cubit.state.remember, isTrue);
    expect(cubit.state.rememberedEmail, 'ada@example.com');
    cubit.close();
  });

  test('a login sends the trimmed email and the Remember me choice', () async {
    final cubit = LoginCubit()..setRemember(false);
    await cubit.login(email: '  ada@example.com ', password: 'Lovelace1815');
    expect(cubit.state.loadingState, AppLoadingState.success);
    expect(remote.calls.single, (
      email: 'ada@example.com',
      password: 'Lovelace1815',
      remember: false,
    ));
    await cubit.close();
  });

  test('a failed login says why, every time it fails', () async {
    remote.error = const AppException(message: 'Wrong email or password');
    final cubit = LoginCubit();
    final states = <LoginState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.login(email: 'ada@example.com', password: 'nope');
    await cubit.login(email: 'ada@example.com', password: 'nope');
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.loadingState, AppLoadingState.failure);
    expect(cubit.state.error, 'Wrong email or password');
    // Loading in between, so a listener sees the second failure too.
    expect(states.map((s) => s.loadingState), [
      AppLoadingState.loading,
      AppLoadingState.failure,
      AppLoadingState.loading,
      AppLoadingState.failure,
    ]);
    await subscription.cancel();
    await cubit.close();
  });
}
