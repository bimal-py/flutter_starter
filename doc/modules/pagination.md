# Pagination

Everything a paged list needs: one page size for the whole app, typed pages, list folding, and widgets that ask for the next page near the end (or when a short page can't scroll). Keep it whenever a list comes from an API in pages.

## What it provides

- `PaginationConstants.defaultPageSize` (15): the only page size.
- `PaginationHelper.query(offset:)`: the `{limit, offset}` every paged request sends. `updateList(newPage:, existingList:, isRefresh:, idOf:)` folds a page into the list. `everyPage(fetch)` collects a short list whole, a page at a time.
- `PaginatedEntity<T>` (domain) and `PaginationModel` (data), both with `nextOffset()`; `PaginationMapper.fromEnvelope(json, itemMapper)` turns a reply into a typed page.
- Widgets: `PaginationScrollBuilder` (scroll controller + auto-fill), `PaginationListener`, `PaginationLoadingFooter` (shimmer rows while the next page loads), plus `ListPaginatedView`, `GridPaginatedView`, `HorizontalPaginatedView`, `CustomPaginatedListView`.
- `searchDebounceDuration` (500 ms) and `debounceRestartable` for Bloc search events.
- `PaginatedListState` (in `lib/common/bloc/`): a state mixin, and `bloc.awaitSettled()` for pull-to-refresh.

## Depends on

`skeletonizer` (footer shimmer), `stream_transform` (debounce). The backend pages with `?limit=&offset=` and answers `{count, next, previous, results}`.

## Setup

Nothing to set up.

## Use

The full example is in [adding a module](../adding_a_module.md) (repository → cubit → list). The essentials:

```dart
// Repository
final response = await _remote.getResponse(
  endPoint: ProductApiRoute.products,
  queryParameters: PaginationHelper.query(offset: offset),
  isTokenRequired: true,
);
final envelope = ApiResponseEnvelope.asPaginationEnvelope(response)!;
return PaginationMapper.fromEnvelope(envelope, ProductMapper.fromJsonToEntity);

// Cubit: next page
final next = state.page?.nextOffset(); // null: no more pages
```

```dart
// List widget (below the BlocBuilder that produces the rows)
PaginationScrollBuilder(
  onLoadMore: context.read<ProductsCubit>().loadMore,
  builder: (context, controller) => ListView.builder(
    controller: controller,
    itemCount: products.length + 1,
    itemBuilder: (_, i) => i == products.length
        ? PaginationLoadingFooter(isLoading: isLoadingMore)
        : ProductTile(product: products[i]),
  ),
);
```

## Remove

1. Delete `lib/modules/pagination/` and `lib/common/bloc/paginated_list_state.dart` (and its export in `lib/common/bloc/bloc.dart`).
2. Remove `stream_transform` from `pubspec.yaml` if nothing else uses it.
3. `flutter analyze`.

## Hidden details

- Never pass a page size per list. Change `defaultPageSize` once if the backend needs a different number.
- The next offset comes from the server's `next` URL, never from `page * limit`, so the list stays right when rows are added or removed while scrolling. `idOf` in `updateList` drops rows that moved onto the next page.
- `PaginatedEntity` is deliberately not `Equatable`: a refresh that returns the same page must still be a new state, or a waiting `RefreshIndicator` never stops.
- `PaginationListener` pulls more pages while the list is too short to scroll (tall screens, short pages), up to 20 in a row as a safety brake. It must sit below the `BlocBuilder` that builds the rows, or it never re-checks.
- Rows that aren't JSON objects are skipped, so one bad row costs one item, not the page.
