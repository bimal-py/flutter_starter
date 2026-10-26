import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class _MemoryStorage implements Storage {
  final values = <String, dynamic>{};

  @override
  dynamic read(String key) => values[key];

  @override
  Future<void> write(String key, dynamic value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<void> close() async {}
}

void main() {
  const shipped = SeedOnlySource(seed: Color(0xFF00695C));
  const rebranded = SeedOnlySource(seed: Color(0xFFB00020));

  late _MemoryStorage storage;

  setUp(() {
    storage = _MemoryStorage();
    HydratedBloc.storage = storage;
  });

  test('a restart keeps the saved choices but takes the source from code', () {
    ThemeCubit(developerSource: shipped)
      ..setVariant(ThemeVariant.dark)
      ..setUserSeed(const Color(0xFFABCDEF));

    final restarted = ThemeCubit(developerSource: rebranded);

    expect(storage.values.keys, ['ThemeCubit']);
    expect(restarted.state.variant, ThemeVariant.dark);
    expect(identical(restarted.state.developerSource, rebranded), isTrue);
    final override = restarted.state.userOverride! as SeedOnlySource;
    expect(override.seed.toARGB32(), 0xFFABCDEF);
  });

  test('clearing the override shows the current developer source', () {
    ThemeCubit(developerSource: shipped).setUserSeed(const Color(0xFFABCDEF));

    final restarted = ThemeCubit(developerSource: rebranded)
      ..clearUserOverride();

    expect(identical(restarted.state.effectiveSource, rebranded), isTrue);
  });

  test('an override that cannot be rebuilt gives way to the source', () {
    storage.values['ThemeCubit'] = {
      'variant': 'light',
      'userOverride': {'kind': 'fullCustom'},
    };

    final cubit = ThemeCubit(developerSource: shipped);

    expect(cubit.state.userOverride, isNull);
    expect(identical(cubit.state.effectiveSource, shipped), isTrue);
  });

  test('a custom variant comes back with its brightness', () {
    ThemeCubit(developerSource: shipped).setVariant(
      const ThemeVariant.custom('amoled', brightness: Brightness.dark),
    );

    final restarted = ThemeCubit(developerSource: shipped);

    expect(restarted.state.variant.id, 'custom:amoled');
    expect(restarted.state.variant.toThemeMode(), ThemeMode.dark);
  });
}
