/// The offset-cursor shape every paginated response exposes, deliberately
/// free of any item type.
///
/// Both the raw-JSON `PaginationModel` and the typed [PaginatedEntity]
/// implement it, so the shared paginated views accept either one.
abstract interface class PaginationPage {
  int get count;
  String get next;
  String get previous;

  int? nextOffset();
  int? previousOffset();
}

/// One page of already-mapped domain objects.
///
/// Built at the repository, where the item mapper is known, so blocs never
/// receive raw JSON.
///
/// Intentionally NOT Equatable and intentionally NOT const-constructible: two
/// pages carrying identical contents must stay distinguishable. Value equality
/// (or a canonicalised const instance) would let a refresh that returns the
/// same page emit a state BLoC suppresses, leaving every awaiting
/// `RefreshIndicator` spinning forever.
class PaginatedEntity<T> implements PaginationPage {
  PaginatedEntity({
    this.count = 0,
    this.next = '',
    this.previous = '',
    this.results = const [],
  });

  @override
  final int count;

  @override
  final String next;

  @override
  final String previous;

  final List<T> results;

  @override
  int? nextOffset() {
    try {
      if (next.isNotEmpty) {
        final Uri uri = Uri.parse(next);
        return int.tryParse(uri.queryParameters['offset'] ?? '');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  int? previousOffset() {
    try {
      if (previous.isNotEmpty) {
        final Uri uri = Uri.parse(previous);
        return int.tryParse(uri.queryParameters['offset'] ?? '');
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
