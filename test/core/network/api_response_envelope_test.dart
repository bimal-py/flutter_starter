import 'package:flutter_starter/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an object comes out of a data envelope, or as it is', () {
    expect(ApiResponseEnvelope.asObject({'id': 1}), {'id': 1});
    expect(
      ApiResponseEnvelope.asObject({
        'data': {'id': 1},
      }),
      {'id': 1},
    );
    expect(ApiResponseEnvelope.asObject([1, 2]), isNull);
  });

  test('a page is found at the top or under data', () {
    final page = {'count': 0, 'results': <Object>[]};
    expect(ApiResponseEnvelope.asPaginationEnvelope(page), page);
    expect(ApiResponseEnvelope.asPaginationEnvelope({'data': page}), page);
    expect(ApiResponseEnvelope.asPaginationEnvelope({'id': 1}), isNull);
  });
}
