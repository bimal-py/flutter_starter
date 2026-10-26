import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/pagination/domain/domain.dart';

class PaginationModel implements PaginationPage {
  @override
  int count;
  @override
  String next;
  @override
  String previous;
  List<dynamic> results;

  PaginationModel({
    this.count = 0,
    this.next = "",
    this.previous = "",
    this.results = const [],
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    final results = json["results"];
    return PaginationModel(
      count: json["count"] is int ? json["count"] as int : 0,
      next: json["next"]?.toString() ?? "",
      previous: json["previous"]?.toString() ?? "",
      results: results is List ? List<dynamic>.from(results) : [],
    );
  }

  @override
  int? nextOffset() {
    try {
      if (!(next.isNullOrEmpty)) {
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
      if (!(previous.isNullOrEmpty)) {
        final Uri uri = Uri.parse(previous);
        return int.tryParse(uri.queryParameters['offset'] ?? '');
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
