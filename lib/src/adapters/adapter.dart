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
    logger.log(LogModule.adapter, "doRequestHelper", detail: "requestURL: $requestURL", level: Level.FINEST);
    final Map<String, String> headers = setupRequestHeaders(request, meta);
    logger.log(LogModule.adapter, "doRequestHelper", detail: "API headers: ${jsonEncode(headers)}", level: Level.FINEST);
    final Map<String, String> newHeaders = _filterHeaders(headers, meta);
    final Map<String, dynamic> adaptRequestBody = await convertRequest(request, meta);
    logger.log(LogModule.adapter, "doRequestHelper", detail: "adaptRequestBody: ${jsonEncode(adaptRequestBody)}", level: Level.FINEST);

    if(meta.isStream) {
      Response response = await ApiClient.requestSSE(requestMethod, requestURL, newHeaders, jsonEncode(adaptRequestBody),
        onRequestSent: () async => _releaseApiKey(meta)
      );
      return doResponse(response, meta);
    } else {
      Response response = await ApiClient.request(requestMethod, requestURL, newHeaders, jsonEncode(adaptRequestBody),
        onRequestSent: () async => _releaseApiKey(meta)
      );
      return doResponse(response, meta);
    }
  }

  Map<String, String> _filterHeaders(Map<String, String> headers, Meta meta) {
    Map<String, String> newHeaders = {};
    newHeaders.addAll(headers);

    newHeaders.removeWhere((key, value) {
      return (
        key.toLowerCase() == 'content-length' ||
        key.toLowerCase() == 'host' ||
        key.toLowerCase() == 'authorization'
      );
    });

    String? authorizationKey = null;
    switch(meta.indexApiKey.type) {
      case ApiKeyType.basic: authorizationKey = "Basic ${meta.indexApiKey.apiKey}";break;
      case ApiKeyType.bearer: authorizationKey = "Bearer ${meta.indexApiKey.apiKey}";break;
      case ApiKeyType.none: authorizationKey = null;break;
    }
    if(authorizationKey != null) {
      newHeaders["Authorization"] = authorizationKey;
    }

    return newHeaders;
  }

  void _releaseApiKey(Meta meta) {
    adapterKeyPools[meta.adapterName]?.release(meta.indexApiKey.id);
  }
}

abstract class ResponseHandler {
  Response handle(Response response);
  Response handleStream(Response response);
}

