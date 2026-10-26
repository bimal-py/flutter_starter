import 'package:dio/dio.dart';
import 'package:flutter_starter/core/network/dio/error_handler/error_handler.dart';

/// Turns a [DioException] into the message shown to the user.
///
/// The backend answers failures with
/// `{status: false, message, data: null, errors: {fields: {...}} | {detail} | {field: [..]}}`
/// and a readable `message`. The server `message` wins unless it is the
/// generic [ApiErrorStrings.genericServerMessage], in which case the first
/// specific error is used; status-code copy is the last resort (e.g. an HTML
/// error page).
class DioExceptionUtil {
  DioExceptionUtil._();

  static String handleError(DioException error) {
    return switch (error.type) {
      DioExceptionType.cancel => ApiErrorStrings.requestCancelled,
      DioExceptionType.connectionError => ApiErrorStrings.cannotReachServer,
      DioExceptionType.connectionTimeout => ApiErrorStrings.requestTimedOut,
      DioExceptionType.receiveTimeout => ApiErrorStrings.requestTimedOut,
      DioExceptionType.transformTimeout => ApiErrorStrings.requestTimedOut,
      DioExceptionType.sendTimeout => ApiErrorStrings.sendTimeout,
      DioExceptionType.badCertificate => ApiErrorStrings.badCertificate,
      DioExceptionType.badResponse => _handleResponseError(error.response),
      DioExceptionType.unknown =>
        error.response == null
            ? ApiErrorStrings.cannotReachServer
            : _handleResponseError(error.response),
    };
  }

  /// Field errors from a 400 (`errors.fields` or the bare `errors` map), for
  /// forms that highlight individual inputs.
  static Map<String, dynamic>? fieldErrors(DioException error) {
    final body = error.response?.data;
    if (body is! Map<String, dynamic>) return null;
    final errors = body['errors'];
    if (errors is! Map<String, dynamic>) return null;
    final fields = errors['fields'];
    return fields is Map<String, dynamic> ? fields : errors;
  }

  static String _handleResponseError(Response<dynamic>? response) {
    final message = _serverMessage(response?.data);
    if (message != null) return message;
    return switch (response?.statusCode ?? 0) {
      400 => ApiErrorStrings.badRequest,
      401 => ApiErrorStrings.sessionExpired,
      403 => ApiErrorStrings.forbidden,
      404 => ApiErrorStrings.notFound,
      429 => ApiErrorStrings.tooManyRequests,
      final code when code >= 500 => ApiErrorStrings.serverError,
      _ => ApiErrorStrings.unknownError,
    };
  }

  static String? _serverMessage(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    final message = body['message'];
    if (message is String &&
        message.isNotEmpty &&
        message != ApiErrorStrings.genericServerMessage) {
      return message;
    }
    final errors = body['errors'];
    if (errors is Map<String, dynamic>) {
      final specific = errors['message'] ?? errors['detail'];
      if (specific != null) return specific.toString();
      return _firstError(errors);
    }
    return _firstError(body['detail']);
  }

  static String? _firstError(Object? value) {
    if (value is String) return value.isEmpty ? null : value;
    if (value is List && value.isNotEmpty) return _firstError(value.first);
    if (value is Map && value.isNotEmpty) {
      return _firstError(value.values.first);
    }
    return null;
  }
}
