# User

The signed-in person: one `UserEntity` / `UserModel`, a copy saved on the phone, and a fetch of `users/me/`. `AuthBloc` follows the saved copy, so every screen shows the same user. Keep it with the [auth](auth.md) module.

## What it provides

- `UserEntity`: `id`, `fullName`, `username`, `email`, `phone`, `gender`, `joinedAt`, `avatar`, `birthday`, and `initials` for avatar placeholders.
- `UserModel` + `UserMapper`: `users/me/` JSON (`full_name`, `avatar_url`, `dob`, `joined_at`, ...). Names go through `capitalizeWords`.
- `LocalUserRepository`: the saved user (`user`), `watchUser()`, `saveUser`, `clear`. Hive box `auth_user_box`.
- `RemoteUserRepository.fetchUser()`: `GET users/me/`.
- Use cases: `GetSavedUserUseCase`, `WatchUserUseCase`, `UpdateLocalUserUseCase`, `FetchUserUseCase`.

## Depends on

[Network](../core/network.md) for the fetch, Hive for the saved copy. Nothing else.

## Setup

1. Point `UserApiRoute.me` at your backend's "who am I" endpoint.
2. Match `UserModel.fromJson` to its fields. The reply may be the user itself or `{"user": {...}}`; both work.

## Use

```dart
// Read who is signed in (rebuilds on change):
final user = context.select((AuthBloc bloc) => bloc.state.user);
Text(user?.fullName ?? '');

// A screen got a fresher copy of the user from the server:
await getIt<UpdateLocalUserUseCase>().execute(updatedUser);
```

To add a field: add it to `UserModel` (all five JSON members and `copyWith`), `UserEntity` (+ `props`) and both directions of `UserMapper`.

## Remove

Remove it together with auth (see [auth → Remove](auth.md#remove)): delete `lib/modules/user/`, drop `openAuthUserBox` / `clearAuthUserBox` from `lib/app/hive_bootstrap.dart`, then `dart run build_runner build`.

## Hidden details

- Don't call `users/me/` to find out who is signed in; `AuthBloc` already holds the user. `FetchUserUseCase` is for sign-in and for a user saved before this copy existed.
- `UpdateLocalUserUseCase` ignores a user with a different `id` than the one signed in, so a reply about someone else can't replace the account.
- `saveUser` skips the write when nothing changed, so watchers don't rebuild for an identical copy.
- An unreadable saved copy is treated as "no user"; the next server reply replaces it.
