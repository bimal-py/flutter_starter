# Errors and messages

How a failure becomes text a person can read, and how text reaches the screen: exceptions, copy classes, toasts, confirmation dialogs, the popup loader and the error views.
The rule: every error the user sees goes through `AppErrorHandler.getErrorMessage(e)`. Never show `'$e'` or `e.toString()`, and never use `ScaffoldMessenger`; toasts go through `CustomSnackbar.show`.

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
| `ServerException` | every `RemoteService` failure; a reply with the wrong shape | `statusCode` (null: server not reached, or a wrong-shape reply), `isRejected` (4xx) |
| `CacheException` | meant for a local read or write that fails; nothing throws it yet (Hive and secure storage errors pass through as they are) | |
| `AuthenticationException` | a sign-in specific failure | |
| `ParseException` | meant for a reply that can't be parsed; nothing throws it yet (a wrong-shape reply is a `ServerException`) | |

`AppErrorHandler.getErrorMessage(error)` returns `AppErrorStrings.noInternetConnection` for a `SocketException`, `error.message` for any `AppException`, and `AppErrorStrings.somethingWentWrong` for anything else.

Where copy lives:

- Generic failures: `AppErrorStrings` (`somethingWentWrong`, `tryAgain`, `invalidResponseShape`, `missingRequiredField`, `operationFailed`, `noInternetConnection`, `pageNotFound`).
- Shared non-error text: `CommonStrings`.
- A feature's success and info text: `<Feature>Strings` in `utils/constants/<feature>_strings.dart`.
- A feature's failure text, thrown and shown: `<Feature>Error` in `utils/constants/<feature>_error.dart` (`AuthError`, `UserError`).

## How to use

Throw from the data layer with feature copy, as `RemoteUserRepositoryImpl.fetchUser` does:

```dart
if (user == null || user['id'] == null) {
  throw const ServerException(message: UserError.invalidReply);
}
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

Failure states. Inline, with nothing else on screen: `ErrorView(message: state.error, onRetry: cubit.load)`. Its `title` defaults to "Something went wrong", `retryLabel` to "Try again", the picture to `AssetRoutes.noDataFound`. Full page: `ErrorScreen(message: ...)`, with a "Go back" button that pops, or goes to the splash route (`/`) when there is nothing to pop. With data already on screen, show a toast instead.

## How to change / extend

**Add a feature's copy**

1. Create `lib/modules/<feature>/utils/constants/<feature>_strings.dart` with `class <Feature>Strings { <Feature>Strings._(); static const String created = '...'; }`.
2. Put failure text in `<feature>_error.dart` (`<Feature>Error`).
3. Export both from the folder's `constants.dart` barrel.
4. Reuse `AppErrorStrings` and `CommonStrings` instead of declaring "Try again" again.

**Add an exception type**

1. Subclass `AppException` in `exceptions.dart`: `const XException({required super.message, super.code});`.
2. `getErrorMessage` already returns its `message`. Add a branch only if it needs different text.

**Change toast colors or position**: edit `CustomSnackbar._backgroundFor`, or pass `backgroundColor:`, `gravity:` or `toastLength:` to one call. Only `ToastGravity.TOP`, `CENTER` and `BOTTOM` work (any other value shows at the bottom), and `toastLength` is Android only: iOS keeps a toast up for `timeInSecForIosWeb` seconds (2).

**Add a dialog type**: add a value to `DialogType` and give it an `icon` and an `accentColor` in `DialogTypeX` (`dialog_type.dart`).

## Hidden details

- Toasts are native (fluttertoast): an Android `Toast` or an iOS view, shown without a context. They survive navigation and need no `Scaffold`, but they don't follow the theme or the app font. Colors are fixed: success green, error red, info orange (not the blue of `customTheme.info`).
- `CustomSnackbar.show` cancels the toast on screen first: only the latest one shows.
- While the popup loader shows, the back button does nothing: it neither closes the loader (`closeOnBackButton: false`) nor pops the page (`GlobalLoaderOverlay`'s `disableBackButton`, on by default). Hide it on success and on failure, or the user is stuck. `hidePopupLoading()` does nothing when it isn't showing.
- The loader's barrier is transparent but covers the whole screen, so taps don't reach the page behind it. `LoadingOverlayWidget` sits in `MaterialApp.router`'s `builder` (`StarterAppView`, `lib/app/app_view.dart`), above the root navigator: it also covers dialogs, and `PopupLoadingCard` gets the app's theme, dark mode included.
- `GlobalLoaderOverlay` wraps everything below it, every route included, in `Directionality(textDirection: TextDirection.ltr)` unless it is given a `textDirection`. `LoadingOverlayWidget` gives none, so pass `textDirection: Directionality.of(context)` there before adding a right-to-left language.
- `showConfirmationDialog` returns `false` for "Cancel" and for a tap outside. It uses the root navigator by default. `showCancelButton: false` gives a one-button dialog; `DialogType.danger` paints the confirm button with `colorScheme.error`.
- The dialog's cancel label falls back to `CommonStrings.cancel` ("Cancel") when `cancelText` is null.
- `getErrorMessage` doesn't know `DioException`: `RemoteService` already turns it into a `ServerException`. A raw Dio call of your own ends up as "Something went wrong".
- `UrlHelper` throws `AppException`s with English text ("Could not open ..."); show them through `getErrorMessage` like any other error.
- A failure with data on screen is a toast, not an `ErrorView`: the user keeps what they were looking at.
