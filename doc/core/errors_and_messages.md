# Errors and messages

How a failure becomes text a person can read, and how text reaches the screen: exceptions, copy classes, toasts, confirmation dialogs, the popup loader and the error views.
The rule: every caught error goes through `AppErrorHandler.getErrorMessage(e)`. Never show `'$e'` or `e.toString()`, and never use `ScaffoldMessenger`; toasts go through `CustomSnackbar.show`.

## Where it lives

```
lib/core/errors/
├── exceptions.dart          AppException and its subclasses
├── error_handler.dart       AppErrorHandler.getErrorMessage(error)
└── app_error_strings.dart   AppErrorStrings: generic failure copy
lib/core/utils/constants/common_strings.dart   CommonStrings: shared copy (loading, goBack, cancel, done)
lib/core/utils/helpers/custom_snackbar.dart    CustomSnackbar.show, ToastType
lib/core/utils/helpers/dialog/                 DialogUtils.showConfirmationDialog, DialogType
lib/common/widgets/loading/                    context.showPopupLoading() / hidePopupLoading()
lib/common/widgets/error/                      ErrorView (inline), ErrorScreen (full page)
lib/modules/<feature>/utils/constants/         <feature>_strings.dart, <feature>_error.dart
```

HTTP failure copy (`ApiErrorStrings`, `DioExceptionUtil`) belongs to the [network](network.md) layer.

| Exception | Thrown when | Extra |
|---|---|---|
| `AppException` | base class: a failure with a message for the user | `message`, `code` |
| `ServerException` | every `RemoteService` failure; a reply with the wrong shape | `statusCode` (null: server not reached), `isRejected` (4xx) |
| `CacheException` | a local read or write fails | |
| `AuthenticationException` | a sign-in specific failure | |
| `ParseException` | a reply that can't be parsed | |

`AppErrorHandler.getErrorMessage(error)` returns `AppErrorStrings.noInternetConnection` for a `SocketException`, `error.message` for any `AppException`, and `AppErrorStrings.somethingWentWrong` for anything else.

Where copy lives:

- Generic failures: `AppErrorStrings` (`somethingWentWrong`, `tryAgain`, `invalidResponseShape`, `missingRequiredField`, `operationFailed`, `noInternetConnection`, `pageNotFound`).
- Shared non-error text: `CommonStrings`.
- A feature's success and info text: `<Feature>Strings` in `utils/constants/<feature>_strings.dart`.
- A feature's failure text, thrown and shown: `<Feature>Error` in `utils/constants/<feature>_error.dart` (`AuthError`, `UserError`).

## How to use

Throw from the data layer with feature copy:

```dart
if (object == null) throw const ServerException(message: UserError.invalidReply);
```

Catch in the cubit, keep the readable message in state:

```dart
try {
  await _saveNote.execute(params);
  emit(state.copyWith(loadingState: AppLoadingState.success));
} catch (error) {
  emit(state.copyWith(
    loadingState: AppLoadingState.failure,
    error: AppErrorHandler.getErrorMessage(error),
  ));
}
```

Toasts, from anywhere (no `BuildContext`):

```dart
CustomSnackbar.show(type: ToastType.success, message: NoteStrings.created);
CustomSnackbar.show(type: ToastType.error, message: AppErrorHandler.getErrorMessage(e));
CustomSnackbar.show(type: ToastType.info, message: NoteStrings.syncing);
```

A submit (save, login, delete) drives the popup loader from one `BlocListener`:

```dart
BlocListener<SaveNoteCubit, SaveNoteState>(
  listenWhen: (prev, curr) => prev.loadingState != curr.loadingState,
  listener: (context, state) {
    if (state.loadingState.isLoading) {
      context.showPopupLoading();
      return;
    }
    context.hidePopupLoading();
    if (state.loadingState.isSuccess) {
      CustomSnackbar.show(type: ToastType.success, message: NoteStrings.created);
      context.pop();
    } else if (state.loadingState.isFailure) {
      CustomSnackbar.show(
        type: ToastType.error,
        message: state.error ?? AppErrorStrings.somethingWentWrong,
      );
    }
  },
  child: const NoteFormView(),
)
```

Confirm before a destructive action:

```dart
final confirmed = await DialogUtils.showConfirmationDialog(
  context,
  title: NoteStrings.deleteTitle,
  message: NoteStrings.deleteMessage,
  confirmText: NoteStrings.delete,
  dialogType: DialogType.danger, // info, success, warning, danger, question
);
if (confirmed) await cubit.delete(id);
```

Failure states. Inline, with nothing else on screen: `ErrorView(message: state.error, onRetry: cubit.load)`. Its `title` defaults to "Something went wrong", `retryLabel` to "Try again", the picture to `AssetRoutes.noDataFound`. Full page: `ErrorScreen(message: ...)`, which has a "Go back" button. With data already on screen, show a toast instead.

## How to change / extend

**Add a feature's copy**

1. Create `lib/modules/<feature>/utils/constants/<feature>_strings.dart` with `class <Feature>Strings { <Feature>Strings._(); static const String created = '...'; }`.
2. Put failure text in `<feature>_error.dart` (`<Feature>Error`).
3. Export both from the folder's `constants.dart` barrel.
4. Reuse `AppErrorStrings` and `CommonStrings` instead of declaring "Try again" again.

**Add an exception type**

1. Subclass `AppException` in `exceptions.dart`: `const XException({required super.message, super.code});`.
2. `getErrorMessage` already returns its `message`. Add a branch only if it needs different text.

**Change toast colors or position**: edit `CustomSnackbar._backgroundFor`, or pass `backgroundColor:`, `gravity:` or `toastLength:` to one call.

**Add a dialog type**: add a value to `DialogType` and give it an `icon` and an `accentColor` in `DialogTypeX` (`dialog_type.dart`).

## Hidden details

- Toasts are native (fluttertoast): an Android `Toast` or an iOS view, shown without a context. They survive navigation and need no `Scaffold`, but they don't follow the theme or the app font. Colors are fixed: success green, error red, info orange (not the blue of `customTheme.info`).
- `CustomSnackbar.show` cancels the toast on screen first: only the latest one shows.
- The popup loader ignores the back button (`closeOnBackButton: false`). Hide it on success and on failure, or the user is stuck. `hidePopupLoading()` does nothing when it isn't showing.
- The loader's barrier is transparent but covers the whole screen, so taps don't reach the page behind it. It sits above `MaterialApp` (`StarterApp`), so it also covers dialogs.
- For the same reason `PopupLoadingCard` doesn't see the app's `Theme`: its `context.colorScheme` is Flutter's fallback theme (light, default colors, also in dark mode). Give the card fixed colors, or host the loader inside `MaterialApp.builder`, if that matters for your brand.
- `showConfirmationDialog` returns `false` for "Cancel" and for a tap outside. It uses the root navigator by default. `showCancelButton: false` gives a one-button dialog; `DialogType.danger` paints the confirm button with `colorScheme.error`.
- The dialog's cancel label falls back to `'Cancel'` when `cancelText` is null.
- `getErrorMessage` doesn't know `DioException`: `RemoteService` already turns it into a `ServerException`. A raw Dio call of your own ends up as "Something went wrong".
- `UrlHelper` throws `AppException`s with English text ("Could not open ..."); show them through `getErrorMessage` like any other error.
- A failure with data on screen is a toast, not an `ErrorView`: the user keeps what they were looking at.
