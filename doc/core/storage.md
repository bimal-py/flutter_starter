# Storage

Where the app keeps data on the phone: Hive boxes (one per module), flutter_secure_storage for secrets, HydratedBloc for cubit state, and cached_network_image's disk cache for downloaded images.
The rule: Hive for data the app reads back, secure storage for tokens and anything secret, never the other way round.

## Where it lives

```
lib/main.dart                                     HydratedBloc storage, Hive.initFlutter(), Hive.openAllBoxes()
lib/app/hive_bootstrap.dart                       the registry: every box opener and clearer
lib/core/utils/helpers/hive_helper.dart           app box: Hive.openAppBox(), Hive.appBox, Hive.clearAppBox()
lib/core/utils/helpers/secure_storage_helper.dart SecureStorageHelper.instance: write, read, delete, removeAllData
lib/core/di/service_module.dart                   FlutterSecureStorage registration
lib/modules/<feature>/utils/storage_helper/       <Feature>StorageKeys + <feature>_hive.dart (the box extension)
```

| Data | Store | In the starter |
|---|---|---|
| Data the app reads back (cache, drafts, the signed-in user) | Hive, one box per module | `auth_box` (session, remembered email), `auth_user_box` (user), `app_box` (ignored update version) |
| Tokens, passwords, anything secret | `SecureStorageHelper` | access and refresh tokens |
| Cubit state to restore at launch | `HydratedCubit` | `ThemeCubit`, `AppSettingCubit` |
| Images from the network | `CachedNetworkImageWrapper` | nothing yet (meant for avatars and pictures) |

There is no SharedPreferences: Hive covers what it would store. Add `shared_preferences` only for a package that asks for an instance.

## How to use

A module's box: keys derived from the box name, and an extension that is the only way in (the pattern of `lib/modules/auth/utils/storage_helper/`):

```dart
class NoteStorageKeys {
  NoteStorageKeys._();

  static const String boxName = 'note_box';
  static const String notesKey = '${boxName}_notes';
}

extension HiveNoteBoxExtension on HiveInterface {
  Future<Box<dynamic>> openNoteBox() =>
      Hive.openBox<dynamic>(NoteStorageKeys.boxName);

  Box<dynamic> get noteBox => Hive.box<dynamic>(NoteStorageKeys.boxName);

  Future<int> clearNoteBox() => noteBox.clear();
}
```

Read and write in the module's `data/repository/local/` impl. Store JSON strings:

```dart
await Hive.noteBox.put(
  NoteStorageKeys.notesKey,
  NoteMapper.toRawJsonListFromEntityList(notes),
);
final raw = Hive.noteBox.get(NoteStorageKeys.notesKey);
final saved = raw is String ? NoteMapper.fromRawJsonListToEntityList(raw) : <NoteEntity>[];
```

Secrets:

```dart
await SecureStorageHelper.instance.write(AuthStorageKeys.accessTokenKey, token);
final accessToken = await SecureStorageHelper.instance.read(AuthStorageKeys.accessTokenKey);
```

Cubit state that survives a restart: extend `HydratedCubit`, implement `fromJson` / `toJson` and override `storagePrefix` with a fixed string (see `AppSettingCubit` in `lib/modules/app_setting/`).

## The cache-first load flow

A screen that has a saved copy paints it at once and refreshes behind it:

1. Emit `loading`.
2. Read the saved copy. If there is one, emit it as `success`.
3. Fetch from the server. The fetch use case saves the reply before returning it (as `FetchUserUseCase` does).
4. On success, emit the fresh data. It replaces the saved copy on screen.
5. On failure, emit `failure` with the message. With data on screen the screen shows a toast and keeps the data; with nothing on screen it shows `ErrorView` with "Try again".

```dart
Future<void> load() async {
  emit(state.copyWith(loadingState: AppLoadingState.loading));
  final saved = _getSavedNotes.execute(const NoParams()); // Hive reads are sync
  if (saved.isNotEmpty) {
    emit(state.copyWith(loadingState: AppLoadingState.success, notes: saved));
  }
  try {
    final fresh = await _fetchNotes.execute(const NoParams());
    emit(state.copyWith(loadingState: AppLoadingState.success, notes: fresh));
  } catch (error) {
    emit(state.copyWith(
      loadingState: AppLoadingState.failure,
      error: AppErrorHandler.getErrorMessage(error),
    ));
  }
}
```

The screen side (a `BlocListener` for the toast, `ErrorView` only when the list is empty) is in [adding a module](../adding_a_module.md) step 10 and [errors and messages](errors_and_messages.md).

## How to change / extend

**Add a box for a module**

1. `utils/storage_helper/<feature>_storage_keys.dart`: `boxName` plus every key as `'${boxName}_<thing>'`.
2. `utils/storage_helper/<feature>_hive.dart`: the `Hive<Feature>BoxExtension` with `open…`, the getter and `clear…`.
3. In `lib/app/hive_bootstrap.dart`, add `() => Hive.openNoteBox()` to `_boxOpeners` and `() => Hive.clearNoteBox()` to `_boxClearers`.
4. Touch the box only from `data/repository/local/`.

**Store a secret**: add the key to `<Feature>StorageKeys` (namespaced the same way) and use `SecureStorageHelper.instance`.

**Persist cubit state**: extend `HydratedCubit`, override `storagePrefix` with a fixed string, keep `toJson` small, provide it in `lib/app/global_bloc_config.dart` when it is app-wide. The default `storagePrefix` is the runtime type's name, which obfuscated and minified builds change: the saved state would be lost.

**Wipe everything** ("delete my data"): sign out first (`LogoutUseCase`), then `Hive.clearAllBoxes()`, `SecureStorageHelper.instance.removeAllData()`, `HydratedBloc.storage.clear()` and, for downloaded images, `CachedNetworkImageProvider.defaultCacheManager.emptyCache()`. Each clears only its own store. They go around the repositories, so without the sign-out `AuthBloc` isn't told and keeps the old session.

## Hidden details

- Values are strings: a record as JSON (the mapper's `toRawJson…`), a single value such as the remembered email as it is. So there are no Hive `TypeAdapter`s and no codegen. A value that fails to parse counts as "nothing saved": the local repository catches the error (`LocalAuthSessionRepositoryImpl.getSession`, `LocalUserRepositoryImpl.user`), which is why the cache-first `load()` can read outside its `try`.
- Every box is opened in `main()` before `runApp`. `Hive.box(name)` throws for a box that wasn't opened, so a box missing from `_boxOpeners` crashes on first use.
- Logout clears the session and the user only; nothing calls `Hive.clearAllBoxes()`. The remembered email, `app_box` and any other module's box survive logout unless their module clears them (see the [auth module](../modules/auth.md)).
- HydratedBloc 11 uses `hive_ce` and a box named `hydrated_box` in the same documents folder as the app's Hive boxes (`hive` 2.2.3). Never name a box `hydrated_box`. `Hive.clearAllBoxes()` leaves theme and settings state alone.
- The session record is in Hive and the tokens are in secure storage. iOS keeps Keychain entries after the app is deleted, but the Hive record goes with the app, so a reinstall starts signed out; the next sign-in overwrites the old tokens.
- iOS secure storage uses `KeychainAccessibility.first_unlock`: background code (the push handler) can read it while the phone is locked, once it was unlocked after boot.
- On Android, flutter_secure_storage wipes itself when it can't decrypt (`resetOnError`, on by default), for example after a backup is restored to a new phone. `RestoreAuthSessionUseCase` then drops a session that has no refresh token, so the user is just signed out.
- `SecureStorageHelper` looks up `FlutterSecureStorage` in `getIt` on every call: it works only after `configureDependencyInjection()`.
- Secure storage is slow (platform calls). Keep plain flags in Hive; secrets only in secure storage.
- On web, Hive uses IndexedDB and HydratedBloc uses `HydratedStorageDirectory.web`.
