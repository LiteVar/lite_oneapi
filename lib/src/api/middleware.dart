import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import '../config.dart';
import '../define.dart';
import '../utils/logger.dart';

Middleware checkAuthorization() {
  return (Handler innerHandler) {
    return (Request request) async {
      if ((config.mode != null && config.mode!.transparent == true) ||
          env == null) {
        return innerHandler(request);
      }
      final String? authorizationHeader =
          _headerValue(request.headers, 'authorization');
      final String? apiKeyHeader = _headerValue(request.headers, 'x-api-key');
      final List<String> apiKeys = env!.apiKeys;
      if (apiKeys.isNotEmpty) {
        final bool valid = apiKeys.any((String apiKey) {
          return authorizationHeader == 'Bearer $apiKey' ||
              apiKeyHeader == apiKey ||
              apiKeyHeader == 'Bearer $apiKey';
        });
        if (valid) {
          return innerHandler(request);
        }
        if (_isMessagesRequest(request.url.path)) {
          return Response(
            401,
            body: jsonEncode({
              'type': 'error',
              'error': {
                'type': 'authentication_error',
                'message': 'Invalid or missing authorization token',
              },
            }),
            headers: {'content-type': 'application/json'},
          );
        }
        return Response.unauthorized(
          'Invalid or missing authorization token',
        );
      }
      return innerHandler(request);
    };
  };
}

String? _headerValue(Map<String, String> headers, String name) {
  for (final MapEntry<String, String> entry in headers.entries) {
    if (entry.key.toLowerCase() == name.toLowerCase()) {
      return entry.value;
    }
  }
  return null;
}

bool _isMessagesRequest(String path) {
  final String normalizedPath = path.startsWith('/') ? path : '/$path';
  return getByPath(normalizedPath) == RelayMode.Messages;
}

Middleware logRequest() {
  return (Handler innerHandler) {
    return (Request request) async {
      String method = request.method;
      String uri = request.requestedUri.toString();
      String body = await request.readAsString();
      logger.log(LogModule.api, "logRequest",
          detail: "[$method] $uri $body", level: Level.FINE);
      Request newRequest = request.change(body: body);
      return innerHandler(newRequest);
    };
  };
}
