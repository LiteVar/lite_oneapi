import 'dart:convert';

import 'package:dart_openai_sdk/dart_openai_sdk.dart' show RequestFailedException;

class LiteOneApiErrorMapper {
  const LiteOneApiErrorMapper._();

  static void throwIfBusinessErrorMap(
    Map<String, dynamic> body, {
    required int statusCode,
  }) {
    if (_isOpenAiError(body)) {
      final dynamic error = body['error'];
      if (error is Map<String, dynamic>) {
        final String message = error['message']?.toString() ?? jsonEncode(error);
        throw RequestFailedException(message, statusCode);
      }
      throw RequestFailedException(error.toString(), statusCode);
    }

    if (_isRemoteBusinessError(body)) {
      final String message = body['message']?.toString() ??
          body['data']?.toString() ??
          'Remote service error (code: ${body['code']})';
      throw RequestFailedException(message, statusCode);
    }
  }

  static String extractErrorMessage(
    String rawBody, {
    required int statusCode,
  }) {
    try {
      final dynamic decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        if (_isOpenAiError(decoded)) {
          final dynamic error = decoded['error'];
          if (error is Map<String, dynamic>) {
            return error['message']?.toString() ?? jsonEncode(error);
          }
          return error.toString();
        }

        if (_isRemoteBusinessError(decoded)) {
          return decoded['message']?.toString() ??
              decoded['data']?.toString() ??
              'Remote service error (code: ${decoded['code']})';
        }
      }
    } catch (_) {
      // Fall back to raw body below.
    }

    return 'HTTP $statusCode: $rawBody';
  }

  static bool _isOpenAiError(Map<String, dynamic> body) {
    return body['error'] != null;
  }

  static bool _isRemoteBusinessError(Map<String, dynamic> body) {
    final dynamic code = body['code'];
    return code is int && code != 0 && body.containsKey('message');
  }
}
