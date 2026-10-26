import 'package:flutter_starter/modules/pagination/domain/domain.dart';
import 'package:flutter_starter/modules/pagination/utils/constants/constants.dart';

/// Folds a freshly-fetched page of entities into a running list so blocs don't
/// re-implement the append-vs-replace dance for every paginated screen, and
/// builds the `?limit=&offset=` every paged request sends.
class PaginationHelper {
  PaginationHelper._();

  /// The paging part of a request: [offset] rows skipped, the app's page size
  /// ([PaginationConstants.defaultPageSize]) asked for.
  static Map<String, dynamic> query({int offset = 0}) => {
    'limit': PaginationConstants.defaultPageSize,
    'offset': offset,
  };

  /// On [isRefresh] the page replaces the list (first page / pull-to-refresh);
  /// otherwise it's appended (load-more).
  ///
  /// Both branches build a fresh list, so the list a state holds never aliases
  /// [newPage]'s own `results`.
  ///
  /// With [idOf], a row that is already in the list is not appended again:
  /// rows can move between pages while the user scrolls.
  static List<T> updateList<T>({
    required PaginatedEntity<T> newPage,
    required List<T> existingList,
    bool isRefresh = false,
    Object? Function(T item)? idOf,
  }) {
    if (isRefresh) return [...newPage.results];
    if (idOf == null) return [...existingList, ...newPage.results];
    final seen = {for (final item in existingList) idOf(item)};
    return [
      ...existingList,
      for (final item in newPage.results)
        if (seen.add(idOf(item))) item,
    ];
  }

  /// Every row of a paged list, a page at a time, for the few short lists a
  /// screen needs whole. [page] fetches the page that starts at an offset.
  static Future<List<T>> everyPage<T>(
    Future<PaginatedEntity<T>> Function(int offset) page,
  ) async {
    final rows = <T>[];
    int? offset = 0;
    while (offset != null) {
      final fetched = await page(offset);
      rows.addAll(fetched.results);
      offset = fetched.nextOffset();
    }
    return rows;
  }
}
