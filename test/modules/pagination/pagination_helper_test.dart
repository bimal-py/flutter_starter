import 'package:flutter_starter/modules/pagination/pagination.dart';
import 'package:flutter_test/flutter_test.dart';

PaginatedEntity<int> _page(List<int> rows, {String next = ''}) =>
    PaginatedEntity<int>(count: 6, next: next, results: rows);

void main() {
  test('every request asks for the app\'s page size', () {
    expect(PaginationHelper.query(offset: 20), {
      'limit': PaginationConstants.defaultPageSize,
      'offset': 20,
    });
  });

  test('a refresh replaces the list; load more appends to it', () {
    expect(
      PaginationHelper.updateList(
        newPage: _page([3, 4]),
        existingList: [1, 2],
        isRefresh: true,
      ),
      [3, 4],
    );
    expect(
      PaginationHelper.updateList(newPage: _page([3, 4]), existingList: [1, 2]),
      [1, 2, 3, 4],
    );
  });

  test('a row that moved to the next page is not shown twice', () {
    expect(
      PaginationHelper.updateList(
        newPage: _page([2, 3]),
        existingList: [1, 2],
        idOf: (row) => row,
      ),
      [1, 2, 3],
    );
  });

  test('everyPage follows next until there is none', () async {
    final asked = <int>[];
    final rows = await PaginationHelper.everyPage<int>((offset) async {
      asked.add(offset);
      return switch (offset) {
        0 => _page([1, 2], next: 'https://api.test/items?limit=2&offset=2'),
        2 => _page([3, 4], next: 'https://api.test/items?limit=2&offset=4'),
        _ => _page([5, 6]),
      };
    });
    expect(asked, [0, 2, 4]);
    expect(rows, [1, 2, 3, 4, 5, 6]);
  });

  test('a malformed row is skipped, not the whole page', () {
    final page = PaginationMapper.fromEnvelope<int>({
      'count': 2,
      'next': null,
      'previous': null,
      'results': [
        {'id': 1},
        'not an object',
        {'id': 2},
      ],
    }, (json) => json['id'] as int);
    expect(page.results, [1, 2]);
    expect(page.count, 2);
    expect(page.nextOffset(), isNull);
  });
}
