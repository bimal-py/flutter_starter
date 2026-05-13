import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_starter/core/network/dio/error_handler/api_error_strings.dart';

class DioExceptionUtil {
  DioExceptionUtil._();

  static String handleError(DioException error) {
    return switch (error.type) {
      DioExceptionType.cancel => ApiErrorStrings.requestCancelled,
      DioExceptionType.connectionError => ApiErrorStrings.connectionFailed,
      DioExceptionType.connectionTimeout => ApiErrorStrings.requestTimedOut,
      DioExceptionType.receiveTimeout => ApiErrorStrings.requestTimedOut,
      DioExceptionType.sendTimeout => ApiErrorStrings.sendTimeout,
      DioExceptionType.badCertificate => ApiErrorStrings.badCertificate,
      DioExceptionType.badResponse => _handleResponseError(error),
      DioExceptionType.unknown => ApiErrorStrings.unknownError,
    };
  }

  static String _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    final data = error.response?.data;

    return switch (statusCode) {
      400 => _parseValidationErrors(data) ?? ApiErrorStrings.badRequest,
      401 => ApiErrorStrings.unauthorized,
      403 => ApiErrorStrings.forbidden,
      404 => ApiErrorStrings.notFound,
      429 => ApiErrorStrings.tooManyRequests,
      500 => ApiErrorStrings.serverError,
      502 || 503 || 504 => ApiErrorStrings.serviceUnavailable,
      _ => () {
        debugPrint('[DIO ERROR] $statusCode: ${data.toString()}');
        return '${ApiErrorStrings.unknownError} ($statusCode)';
      }(),
    };
  }

  /// Unpacks `{field: [msg]}` / `{errors: {...}}` / `{message: '...'}` shapes
  /// from 400 responses into a single user-facing string. Returns null when
  /// the payload doesn't match any known shape so the caller falls back to
  /// [ApiErrorStrings.badRequest].
  static String? _parseValidationErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final messages = <String>[];

    void extract(dynamic node, String parentKey) {
      if (node is Map<String, dynamic>) {
        node.forEach((key, value) {
          extract(value, _humanizeKey(key));
        });
      } else if (node is List) {
        for (final element in node) {
          extract(element, parentKey);
        }
      } else if (node is String) {
        if (node.contains('null') || node.contains('blank')) {
          messages.add('$parentKey is required');
        } else if (node.contains('unique')) {
          messages.add('$parentKey already exists');
        } else if (node.contains('field is required')) {
          messages.add('$parentKey is required');
        } else {
          messages.add(node);
        }
      }
    }

    if (data.containsKey('errors')) extract(data['errors'], '');
    if (messages.isEmpty && data.containsKey('message')) {
      messages.add(data['message'].toString());
    }

    return messages.isEmpty ? null : messages.join(' & ');
  }

  static String _humanizeKey(String key) {
    final cleaned = key.replaceAll('_', ' ');
    if (cleaned.isEmpty) return cleaned;
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }
}
