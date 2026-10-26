/// The one place the app's page size lives.
class PaginationConstants {
  PaginationConstants._();

  /// How many rows every paged list asks for at a time (`?limit=`). Lists
  /// don't pick their own number: change it here.
  static const int defaultPageSize = 15;
}
