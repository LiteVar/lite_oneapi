import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../../api/meta.dart';
import '../adapter.dart';
import '../../model.dart';
import 'request.dart';

/// Shared transport for provider adapters that speak Anthropic Messages.
/// Provider-specific routes and authentication details live in child adapters.
abstract class MessagesAdapter extends LLMAdapter {
  String get endpointPath;
  bool get replaceBasePath => false;
  String? get hostOverride => null;
  bool get usesBearerAuthorization => false;

  @override
  ResponseHandler get responseHandler => _PassThroughResponseHandler();

  @override
  String get apiKeyHeaderName =>
      usesBearerAuthorization ? 'Authorization' : 'x-api-key';

  @override
  String formatAdapterApiKey(ApiKeyType type, String apiKey) =>
      usesBearerAuthorization ? 'Bearer $apiKey' : apiKey;

  @override
  String formatOriginalApiKey(String value) {
    final String trimmed = value.trim();
    if (usesBearerAuthorization) {
      return trimmed.toLowerCase().startsWith('bearer ')
          ? trimmed
          : 'Bearer $trimmed';
    }
    if (trimmed.toLowerCase().startsWith('bearer ')) {
      return trimmed.substring(7).trim();
    }
    return trimmed;
  }

  @override
  String getRequestMethod(Request request, Meta meta) => request.method;

  @override
  String getRequestURL(Request request, Meta meta) {
    final String path = meta.endpoint ??
        (meta.isCustomBaseUrl ? '/${request.url.path}' : endpointPath);
    String baseUrl = meta.baseUrl;
    if (!meta.isCustomBaseUrl && hostOverride != null) {
      baseUrl = Uri.parse(baseUrl).replace(host: hostOverride).toString();
    }
    if (!meta.isCustomBaseUrl && replaceBasePath) {
      return Uri.parse(baseUrl).replace(path: path, query: '').toString();
    }
    return _joinBaseAndPath(baseUrl, path);
  }

  @override
  Map<String, String> setupRequestHeaders(Request request, Meta meta) {
    final Map<String, String> headers =
        Map<String, String>.from(request.headers);
    headers['content-type'] = 'application/json';
    headers['accept'] =
        meta.isStream ? 'text/event-stream' : 'application/json';
    headers.putIfAbsent('anthropic-version', () => '2023-06-01');
    return headers;
  }

  @override
  Future<Map<String, dynamic>> convertRequest(
      Request request, Meta meta) async {
    final Map<String, dynamic> body = jsonDecode(meta.requestBody);
    return MessagesRequest.fromJson(body).toJson();
  }

  @override
  Future<Response> doRequest(Request request, Meta meta) =>
      doRequestHelper(request, meta);

  @override
  Future<Response> doResponse(Response response, Meta meta) async => response;

  String _joinBaseAndPath(String baseUrl, String path) {
    final Uri base = Uri.parse(baseUrl);
    final List<String> baseSegments = base.pathSegments
        .where((String segment) => segment.isNotEmpty)
        .toList();
    final List<String> routeSegments =
        path.split('/').where((String segment) => segment.isNotEmpty).toList();
    int overlap = 0;
    final int maxOverlap = baseSegments.length < routeSegments.length
        ? baseSegments.length
        : routeSegments.length;
    for (int count = maxOverlap; count > 0; count--) {
      final List<String> suffix =
          baseSegments.sublist(baseSegments.length - count);
      final List<String> prefix = routeSegments.sublist(0, count);
      if (_sameSegments(suffix, prefix)) {
        overlap = count;
        break;
      }
    }
    final List<String> combined = <String>[
      ...baseSegments,
      ...routeSegments.skip(overlap),
    ];
    return base.replace(pathSegments: combined, query: '').toString();
  }

  bool _sameSegments(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (int index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}

class _PassThroughResponseHandler implements ResponseHandler {
  @override
  Response handle(Response response) => response;

  @override
  Response handleStream(Response response) => response;
}
