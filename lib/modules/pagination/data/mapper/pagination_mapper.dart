import 'package:flutter_starter/modules/pagination/data/model/model.dart';
import 'package:flutter_starter/modules/pagination/domain/domain.dart';

/// Maps one raw `results` entry from a [PaginationModel] into a domain entity.
typedef PaginationItemMapper<T> = T Function(Map<String, dynamic> json);

/// Turns a raw paginated payload into a page of domain entities.
///
/// Lives in `data` because that is the only layer that knows both the wire
/// model and the item mapper; repositories call it so the page reaching a bloc
/// is already typed.
class PaginationMapper {
  PaginationMapper._();

  /// Maps [model]'s raw `results` with [mapper], carrying the cursor fields
  /// across untouched.
  ///
  /// Entries that are not JSON objects are skipped rather than thrown on, so a
  /// single malformed row degrades to one missing item instead of failing the
  /// whole page.
  static PaginatedEntity<T> toEntity<T>(
    PaginationModel model,
    PaginationItemMapper<T> mapper,
  ) => PaginatedEntity<T>(
    count: model.count,
    next: model.next,
    previous: model.previous,
    results: model.results
        .whereType<Map<String, dynamic>>()
        .map(mapper)
        .toList(),
  );

  /// Convenience for repositories holding the decoded
  /// `{count, next, previous, results}` envelope straight off the wire.
  static PaginatedEntity<T> fromEnvelope<T>(
    Map<String, dynamic> envelope,
    PaginationItemMapper<T> mapper,
  ) => toEntity<T>(PaginationModel.fromJson(envelope), mapper);

  /// Reads just the total from an envelope, for callers that page with
  /// `limit: 1` purely to learn how many records exist.
  static int countOf(Map<String, dynamic> envelope) =>
      PaginationModel.fromJson(envelope).count;
}
