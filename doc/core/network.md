# Network

`RemoteService` (`lib/core/network/`) is the app's only HTTP gateway. Repositories call it; nothing else touches Dio. It returns the decoded JSON body and throws `ServerException` on any failure, so a value coming back already means success.

## Where it lives

```
lib/core/network/
├── dio/
│   ├── config/dio_config.dart         base URL (from API_BASE_URL), timeouts
│   ├── dio_client.dart                Dio + debug LogInterceptor; installs interceptors per request
│   ├── error_handler/                 ApiErrorStrings, DioExceptionUtil (failure → message)
│   └── interceptors/                  AuthInterceptor, LogoutInterceptor, RetryInterceptor,
│                                      TokenRefreshSynchronizer
└── service/
    ├── remote_service.dart            the contract
    ├── remote_service_impl.dart       the Dio implementation (@Injectable)
    ├── auth_token_handler.dart        how the auth module plugs tokens in
    ├── api_response_envelope.dart     unwraps `data` / paginated replies
    ├── cancel_token_manager.dart      cancel every request (logout)
    ├── request_options_extension.dart flags carried on each request
    └── upload_filename.dart           short, safe multipart filenames
```

## How to use

```dart
final response = await _remote.getResponse(
  endPoint: ProductApiRoute.products,          // 'products/' — no leading slash
  queryParameters: PaginationHelper.query(offset: offset),
  isTokenRequired: true,                        // sends Authorization: Bearer <token>
);
final envelope = ApiResponseEnvelope.asPaginationEnvelope(response);
```

| Method | Body |
|---|---|
| `getResponse` | none (query parameters only) |
| `postResponse`, `putResponse`, `patchResponse` | `payloadObj` map; `files: {'avatar': File(path)}` makes it multipart |
| `postListResponse` | a JSON array (`payloadList`) |
| `deleteResponse` | optional `payloadObj` (any JSON) |

Every method takes `baseUrl` (another host), `isTokenRequired`, and `accessToken` (a getter that overrides the stored token). `postResponse` also takes `contentType`, `onSendProgress` and a per-request `cancelToken`.

Errors:

```dart
try {
  await _remote.postResponse(endPoint: ..., payloadObj: ...);
} on ServerException catch (e) {
  e.message;     // readable: the server's message, or status-code copy
  e.statusCode;  // null when the server wasn't reached (offline, timeout)
  e.isRejected;  // 4xx: the request was wrong, not the connection
}
```

Cubits don't catch `ServerException` specifically; they pass any error to `AppErrorHandler.getErrorMessage(e)`.

## What the backend is expected to send

- Success: `{"status": true, "message": "...", "data": {...} | [...]}`, or the object at the top level. `ApiResponseEnvelope.asObject` handles both.
- Lists: `{"count", "next", "previous", "results"}` (Django REST framework limit/offset), at the top level or under `data`.
- Failure: `{"status": false, "message": "...", "errors": {...}}`. `DioExceptionUtil` shows `message`, unless it is the backend's generic text, then `errors.message` / `errors.detail` / the first field error, then copy for the status code.
- Tokens: SimpleJWT. Sign-in replies carry `data.tokens.{access, refresh}`; `auth/token/refresh/` takes `{"refresh"}` and returns `access` (and `refresh` when rotation is on).

A different backend means changing `DioExceptionUtil`, `ApiResponseEnvelope` and the auth repository, not every feature.

## Tokens, refresh and logout

1. `AuthInterceptor` adds `Authorization: Bearer <token>` when `isTokenRequired` is true. The token comes from the `accessToken` argument, or from the `AuthTokenHandler` the auth module registers.
2. On a 401 or 403 for a token request, `RetryInterceptor` refreshes the token once (`AuthTokenHandler.refreshAccessToken`). Parallel failures share one refresh (`TokenRefreshSynchronizer`).
3. It retries up to 3 times, 1 second apart. Network errors (no connection, timeout) are retried too; other 4xx/5xx replies are not.
4. When the retries run out on an auth error, `AuthTokenHandler.onSessionExpired` logs the user out (`AuthBloc` flips to unauthenticated by itself).
5. After a logout, `LogoutInterceptor` fails every new token request fast until the next sign-in. Requests without a token (login, register) still go through.

## How to change / extend

- **Base URL**: `API_BASE_URL` in `.env`. A trailing `/` is trimmed.
- **Timeouts**: `DioConfig` (30 seconds each).
- **Retries**: the defaults (3 retries, 1 second apart, which errors count) are in `RetryOptions` in `retry_interceptor.dart`.
- **Another error shape**: edit `DioExceptionUtil._serverMessage`.
- **No HTTP at all**: delete `lib/core/network/`, `dio` from `pubspec.yaml`, `API_BASE_URL` from `.env`, and the modules that use `RemoteService` (auth, user), then `dart run build_runner build`.

## Hidden details

- Interceptors are installed fresh on every call (`DioClient.addInterceptors` strips all but the logger first), so a request's `isTokenRequired` never leaks into the next one.
- Request and response bodies are logged in debug builds only, and never under `flutter test`.
- `RetryInterceptor` retries 401/403 even for public calls, so the backend should not answer 401/403 as a normal outcome of a public endpoint.
- The backend returns 403 (not 401) for a missing or expired token, which is why both trigger a refresh.
- A logged-out user's pending requests are cancelled (`GlobalCancelTokenManager.cancelAllRequests`).
- Uploaded files get short names (`buildUploadFilename`): picked images otherwise reach the server as long temporary names. The retry path rebuilds the multipart body with the same names.
- The network layer finds the auth module through `getIt.maybeGet<AuthTokenHandler>()` on each request. That is what keeps `core/` free of module imports.
