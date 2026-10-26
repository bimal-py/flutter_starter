/// Unwraps the raw payloads [RemoteService] hands back into the map shapes
/// repositories parse from.
///
/// The backend is inconsistent about envelopes: some endpoints return the
/// resource at the top level, others nest it under `data`. Both guards return
/// `null` when the response does not match the expected shape, which callers
/// translate into a `ServerException` with their own feature-specific message.
class ApiResponseEnvelope {
  ApiResponseEnvelope._();

  /// Detail is a single object, sometimes wrapped under `data`.
  static Map<String, dynamic>? asObject(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return response;
    }
    return null;
  }

  /// DRF lists are `{count,next,previous,results}`, sometimes wrapped under `data`.
  static Map<String, dynamic>? asPaginationEnvelope(dynamic response) {
    if (response is Map<String, dynamic>) {
      if (response['results'] is List) return response;
      final data = response['data'];
      if (data is Map<String, dynamic> && data['results'] is List) return data;
    }
    return null;
  }
}
