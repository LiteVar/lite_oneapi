import 'dart:convert';
import 'package:lite_oneapi/src/adapters/request.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import '../api/meta.dart';
import '../config.dart';
import '../utils/logger.dart';
import '../model.dart';

abstract class LLMAdapter {
  late ResponseHandler responseHandler;

  String get apiKeyHeaderName => 'Authorization';

  String formatAdapterApiKey(ApiKeyType type, String apiKey) {
    switch (type) {
      case ApiKeyType.basic:
        return 'Basic $apiKey';
      case ApiKeyType.bearer:
        return 'Bearer $apiKey';
      case ApiKeyType.none:
        return '';
    }
  }

  String formatOriginalApiKey(String value) => value;

  void init(Meta meta) {}
  String getRequestMethod(Request request, Meta meta);
  String getRequestURL(Request request, Meta meta);
  Map<String, String> setupRequestHeaders(Request request, Meta meta);
  Future<Map<String, dynamic>> convertRequest(Request request, Meta meta);
  Future<Response> doRequest(Request request, Meta meta);
  Future<Response> doResponse(Response response, Meta meta);

  Future<Response> doRequestHelper(Request request, Meta meta) async {
    final String requestMethod = getRequestMethod(request, meta);
    final String requestURL = getRequestURL(request, meta);
    logger.log(LogModule.adapter, "doRequestHelper",
        detail: "requestURL: $requestURL", level: Level.FINEST);
    final Map<String, String> headers = setupRequestHeaders(request, meta);
    logger.log(LogModule.adapter, "doRequestHelper",
        detail: "API headers: ${jsonEncode(_redactHeaders(headers))}",
        level: Level.FINEST);
    final Map<String, String> newHeaders = _filterHeaders(headers, meta);
    final Map<String, dynamic> adaptRequestBody =
        await convertRequest(request, meta);
    logger.log(LogModule.adapter, "doRequestHelper",
        detail: "adaptRequestBody: ${jsonEncode(adaptRequestBody)}",
        level: Level.FINEST);

    if (meta.isStream) {
      Response response = await ApiClient.requestSSE(
          requestMethod, requestURL, newHeaders, jsonEncode(adaptRequestBody),
          onRequestSent: () async => _releaseApiKey(meta));
      return doResponse(response, meta);
    } else {
      Response response = await ApiClient.request(
          requestMethod, requestURL, newHeaders, jsonEncode(adaptRequestBody),
          onRequestSent: () async => _releaseApiKey(meta));
      return doResponse(response, meta);
    }
  }

  Map<String, String> _filterHeaders(Map<String, String> headers, Meta meta) {
    Map<String, String> newHeaders = {};
    newHeaders.addAll(headers);
    final String? providedApiKey = _headerValue(headers, apiKeyHeaderName);

    newHeaders.removeWhere((key, value) {
      return (key.toLowerCase() == 'content-length' ||
          key.toLowerCase() == 'host' ||
          key.toLowerCase() == 'authorization' ||
          key.toLowerCase() == 'api-key' ||
          key.toLowerCase() == 'x-api-key');
    });

    if (meta.useOriginalAuthorization ||
        (config.mode != null && config.mode!.transparent == true) ||
        env == null) {
      final String original = meta.originalApiKeyWithBearer;
      if (original.isNotEmpty) {
        newHeaders[apiKeyHeaderName] = formatOriginalApiKey(original);
      } else if (providedApiKey != null) {
        newHeaders[apiKeyHeaderName] = providedApiKey;
      }
    } else {
      final String? apiKey = meta.indexApiKey!.apiKey;
      if (apiKey != null) {
        final String authorizationKey = formatAdapterApiKey(
          meta.indexApiKey!.type,
          apiKey,
        );
        if (authorizationKey.isNotEmpty) {
          newHeaders[apiKeyHeaderName] = authorizationKey;
        }
      }
    }

    return newHeaders;
  }

  String? _headerValue(Map<String, String> headers, String name) {
    for (final MapEntry<String, String> entry in headers.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase()) return entry.value;
    }
    return null;
  }

  Map<String, String> _redactHeaders(Map<String, String> headers) =>
      headers.map((String key, String value) {
        final String normalized = key.toLowerCase();
        final bool isSecret = normalized == 'authorization' ||
            normalized == 'api-key' ||
            normalized == 'x-api-key';
        return MapEntry<String, String>(key, isSecret ? '[REDACTED]' : value);
      });

  void _releaseApiKey(Meta meta) {
    if (meta.useOriginalAuthorization ||
        (config.mode != null && config.mode!.transparent == true) ||
        env == null) {
      return;
    }
    adapterKeyPools![meta.adapterName]?.release(meta.indexApiKey!.id);
  }
}

abstract class ResponseHandler {
  Response handle(Response response);
  Response handleStream(Response response);
}
