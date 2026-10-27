# Adding a module

A worked example: a `note` module that lists notes from `GET notes/` (paginated) and creates one with `POST notes/`. Mirror it for any feature. Rules behind each step: [conventions](conventions.md).

## 1. Folders

```
lib/modules/note/
├── note.dart
├── data/{data.dart, model/, mapper/, repository/remote/}
├── domain/{domain.dart, entity/, repository/remote/, use_case/remote/}
├── presentation/{presentation.dart, bloc/notes/, views/, widgets/}
└── utils/{utils.dart, constants/}
```

Every folder gets a barrel (`entity/entity.dart` exports `note_entity.dart`, `domain/domain.dart` exports `entity/entity.dart`, `repository/repository.dart`, `use_case/use_case.dart`, and so on up to `note.dart`).

## 2. Entity: `domain/entity/note_entity.dart`

```dart
class NoteEntity extends Equatable {
  const NoteEntity({this.id, this.title, this.body, this.createdAt});

  final String? id;
  final String? title;
  final String? body;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, title, body, createdAt];
}
```

## 3. Model: `data/model/note_model.dart`

```dart
class NoteModel {
  final String? id;
  final String? title;
  final String? body;
  final DateTime? createdAt;

  NoteModel({this.id, this.title, this.body, this.createdAt});

  NoteModel copyWith({String? id, String? title, String? body, DateTime? createdAt}) =>
      NoteModel(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        createdAt: createdAt ?? this.createdAt,
      );

  factory NoteModel.fromRawJson(String str) =>
      NoteModel.fromJson(json.decode(str) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    id: json["id"]?.toString(),
    title: json["title"]?.toString(),
    body: json["body"]?.toString(),
    createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? '')?.toLocal(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "body": body,
    "created_at": createdAt?.toUtc().toIso8601String(),
  };
}
```

## 4. Mapper: `data/mapper/note_mapper.dart`

The ten functions, as in `lib/modules/user/data/mapper/user_mapper.dart`. The two you write by hand:

```dart
static NoteEntity toEntity(NoteModel model) => NoteEntity(
  id: model.id,
  title: model.title,
  body: model.body,
  createdAt: model.createdAt,
);

static NoteModel toModel(NoteEntity entity) => NoteModel(
  id: entity.id,
  title: entity.title,
  body: entity.body,
  createdAt: entity.createdAt,
);
```

## 5. Routes and copy: `utils/constants/`

```dart
class NoteApiRoute {
  NoteApiRoute._();

  static const String notes = 'notes/';
}

class NoteStrings {
  NoteStrings._();

  static const String title = 'Notes';
  static const String created = 'Note saved';
}

class NoteError {
  NoteError._();

  static const String invalidReply = 'We couldn’t read your notes. Please try again.';
}
```

## 6. Repository contract: `domain/repository/remote/remote_note_repository.dart`

```dart
abstract class RemoteNoteRepository {
  /// `GET notes/`, one page starting at [offset].
  Future<PaginatedEntity<NoteEntity>> fetchNotes({int offset = 0});

  Future<NoteEntity> createNote({required String title, required String body});
}
```

## 7. Implementation: `data/repository/remote/remote_note_repository_impl.dart`

```dart
@Injectable(as: RemoteNoteRepository)
class RemoteNoteRepositoryImpl implements RemoteNoteRepository {
  RemoteNoteRepositoryImpl(this._remote);

  final RemoteService _remote;

  @override
  Future<PaginatedEntity<NoteEntity>> fetchNotes({int offset = 0}) async {
    final response = await _remote.getResponse(
      endPoint: NoteApiRoute.notes,
      queryParameters: PaginationHelper.query(offset: offset),
      isTokenRequired: true,
    );
    final envelope = ApiResponseEnvelope.asPaginationEnvelope(response);
    if (envelope == null) {
      throw const ServerException(message: NoteError.invalidReply);
    }
    return PaginationMapper.fromEnvelope(envelope, NoteMapper.fromJsonToEntity);
  }

  @override
  Future<NoteEntity> createNote({required String title, required String body}) async {
    final response = await _remote.postResponse(
      endPoint: NoteApiRoute.notes,
      payloadObj: {'title': title, 'body': body},
      isTokenRequired: true,
    );
    final object = ApiResponseEnvelope.asObject(response);
    if (object == null) throw const ServerException(message: NoteError.invalidReply);
    return NoteMapper.fromJsonToEntity(object);
  }
}
```

## 8. Use cases: `domain/use_case/remote/`

```dart
@injectable
class FetchNotesUseCase extends UseCase<PaginatedEntity<NoteEntity>, FetchNotesUseCaseParams> {
  FetchNotesUseCase(this._repository);

  final RemoteNoteRepository _repository;

  @override
  Future<PaginatedEntity<NoteEntity>> execute(FetchNotesUseCaseParams params) =>
      _repository.fetchNotes(offset: params.offset);
}

class FetchNotesUseCaseParams extends Equatable {
  const FetchNotesUseCaseParams({this.offset = 0});

  final int offset;

  @override
  List<Object?> get props => [offset];
}
```

`CreateNoteUseCase` is the same shape around `createNote`.

## 9. Cubit: `presentation/bloc/notes/notes_cubit.dart`

```dart
part 'notes_state.dart';

class NotesCubit extends SafeCubit<NotesState> {
  NotesCubit() : super(const NotesState());

  final FetchNotesUseCase _fetchNotes = getIt<FetchNotesUseCase>();

  Future<void> load() => _fetch(offset: 0);

  Future<void> refresh() => _fetch(offset: 0);

  Future<void> loadMore() async {
    final next = state.page?.nextOffset();
    if (next == null || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    await _fetch(offset: next);
  }

  Future<void> _fetch({required int offset}) async {
    if (offset == 0) emit(state.copyWith(loadingState: AppLoadingState.loading));
    try {
      final page = await _fetchNotes.execute(FetchNotesUseCaseParams(offset: offset));
      emit(state.copyWith(
        loadingState: AppLoadingState.success,
        isLoadingMore: false,
        page: page,
        notes: PaginationHelper.updateList(
          newPage: page,
          existingList: state.notes,
          isRefresh: offset == 0,
          idOf: (note) => note.id,
        ),
      ));
    } catch (error) {
      emit(state.copyWith(
        loadingState: AppLoadingState.failure,
        isLoadingMore: false,
        error: AppErrorHandler.getErrorMessage(error),
      ));
    }
  }
}
```

```dart
part of 'notes_cubit.dart';

class NotesState extends Equatable with PaginatedListState {
  const NotesState({
    this.loadingState = AppLoadingState.initial,
    this.isLoadingMore = false,
    this.notes = const [],
    this.page,
    this.error,
  });

  @override
  final AppLoadingState loadingState;
  @override
  final bool isLoadingMore;
  final List<NoteEntity> notes;
  final PaginatedEntity<NoteEntity>? page;
  final String? error;

  NotesState copyWith({
    AppLoadingState? loadingState,
    bool? isLoadingMore,
    List<NoteEntity>? notes,
    PaginatedEntity<NoteEntity>? page,
    String? error,
  }) => NotesState(
    loadingState: loadingState ?? this.loadingState,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    notes: notes ?? this.notes,
    page: page ?? this.page,
    error: error,
  );

  @override
  List<Object?> get props => [loadingState, isLoadingMore, notes, page, error];
}
```

## 10. Screen, view, widgets: `presentation/`

```dart
// views/notes_screen.dart
class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotesCubit()..load(),
      child: BlocListener<NotesCubit, NotesState>(
        // A failed refresh or next page with notes on screen: toast, but
        // not as the next page starts (the state is still `failure` then).
        // With nothing on screen the view shows ErrorView instead.
        listenWhen: (prev, curr) =>
            curr.loadingState.isFailure &&
            !curr.isLoadingMore &&
            curr.notes.isNotEmpty,
        listener: (_, state) => CustomSnackbar.show(
          type: ToastType.error,
          message: state.error ?? AppErrorStrings.somethingWentWrong,
        ),
        child: const NotesView(),
      ),
    );
  }
}

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(NoteStrings.title)),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          final cubit = context.read<NotesCubit>();
          if (state.notes.isEmpty && state.loadingState.isFailure) {
            return ErrorView(message: state.error, onRetry: cubit.load);
          }
          if (state.notes.isEmpty && !state.loadingState.isSuccess) {
            return const NoteListSkeleton();
          }
          return NoteList(notes: state.notes, isLoadingMore: state.isLoadingMore);
        },
      ),
    );
  }
}
```

`widgets/note_list.dart` wraps a `ListView` in `PaginationScrollBuilder(onLoadMore: cubit.loadMore, builder: (context, controller) => ...)` with `PaginationLoadingFooter(isLoading: isLoadingMore)` as the last item, inside a `RefreshIndicator(onRefresh: cubit.refresh)`. Give the `ListView` `physics: const AlwaysScrollableScrollPhysics()`: a `ListView` with a controller doesn't get it by default, and without it a list shorter than the screen can't be pulled to refresh. `widgets/note_list_skeleton.dart` is `Skeletonizer(child: NoteList(notes: kNoteListSkeletonDummy))`, with `kNoteListSkeletonDummy` in `utils/constants/note_dummy.dart`.

## 11. Wire it in

1. Route: add `notes(name: 'notes', path: 'notes'), // note` to `Routes` in `lib/core/router/routes.dart`, and a `GoRoute` for it to the dashboard route's `routes:` in `app_router.dart`, under a `// Optional. Remove with lib/modules/note/.` line. A path without a leading `/` matches only as a child: a top-level route needs `path: '/notes'`, or go_router shows the error page. See [routing](core/routing.md#how-to-change--extend).
2. If the module keeps a Hive box: add its opener and clearer to `lib/app/hive_bootstrap.dart`, each under the same marker ([storage](core/storage.md#how-to-change--extend)). The clearer runs only through `Hive.clearAllBoxes()`, which nothing calls: logout clears just the session and the saved user.
3. `dart run build_runner build` (registers the repository and use cases).
4. `flutter analyze`.

## 12. Document it

Add `doc/modules/note.md` (What it provides, Depends on, Setup, Use, Remove, Hidden details) and a row in the [module catalog](modules/README.md).
