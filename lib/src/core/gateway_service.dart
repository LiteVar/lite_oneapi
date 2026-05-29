import 'dart:convert';

import 'package:lite_oneapi/src/adapters/adapter.dart';
import 'package:lite_oneapi/src/adapters/exception.dart';
import 'package:lite_oneapi/src/adapters/model.dart';
import 'package:lite_oneapi/src/api/meta.dart';
import 'package:lite_oneapi/src/config.dart';
import 'package:lite_oneapi/src/model.dart';
import 'package:lite_oneapi/src/utils/pool.dart';
import 'package:lite_oneapi/src/utils/logger.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

class PreparedGatewayRequest {
  final LLMAdapter adapter;
  final Meta meta;

  const PreparedGatewayRequest({
    required this.adapter,
    required this.meta,
  });
}

class LiteOneApiGatewayService {
  Future<Response> handleHttp(Request request) async {
    final String payload = await request.readAsString();
    logger.log(LogModule.api, "Request handle", detail: payload, level: Level.FINEST);

    return handleJsonRequest(
      payload: payload,
      requestPath: request.url.path,
      requestHeaders: request.headers,
      method: request.method,
    );
  }

  Future<Response> handleJsonRequest({
    required String payload,
    required String requestPath,
    required Map<String, String> requestHeaders,
    String method = "POST",
  }) async {
    try {
      final PreparedGatewayRequest prepared = prepareRequest(
        payload: payload,
        requestPath: requestPath,
        requestHeaders: requestHeaders,
      );
      return prepared.adapter.doRequest(
        _buildLocalRequest(
          payload: payload,
          requestPath: requestPath,
          requestHeaders: requestHeaders,
          method: method,
        ),
        prepared.meta,
      );
    } on AdapterNotFoundException catch(e) {
      return Response.notFound(e.toString());
    } on UnsupportedRequestException catch(e) {
      return Response(400, body: jsonEncode(e.toJson()), headers: {"content-type": "application/json"});
    } on PoolExhaustedException catch(e) {
      return Response.internalServerError(body: "Adapter ApiKey error: ${e.toString()}");
    }
  }

  Request _buildLocalRequest({
    required String payload,
    required String requestPath,
    required Map<String, String> requestHeaders,
    required String method,
  }) {
    final String normalizedPath = requestPath.startsWith("/") ? requestPath : "/$requestPath";
    final Uri uri = Uri.parse("http://localhost$normalizedPath");
    return Request(
      method,
      uri,
      body: payload,
      headers: requestHeaders,
    );
  }

  PreparedGatewayRequest prepareRequest({
    required String payload,
    required String requestPath,
    required Map<String, String> requestHeaders,
  }) {
    final Map<String, dynamic> data = jsonDecode(payload);
    final String? customBaseUrl = _readString(data, ["base_url", "baseUrl"]);
    final String? customAdapter = _readString(data, ["adapter", "channel"]);
    final Map<String, dynamic> requestData = _sanitizeRequestData(data);
    final String? model = data["model"];
    logger.log(LogModule.api, "Request handle", detail: "model: $model");

    if (model == null) {
      throw AdapterNotFoundException("NULL");
    }

    Meta meta = Meta(
      model: model,
      isStream: data["stream"] ?? false,
      requestBody: jsonEncode(requestData),
    );

    final ModelInfo? mappedModelInfo = _selectModel(model);
    final ModelInfo? modelInfo = _resolveModelInfo(model, mappedModelInfo, customBaseUrl, customAdapter);
    if (modelInfo == null) {
      throw AdapterNotFoundException(model);
    }
    meta = initModelInfo(meta, modelInfo);
    meta = initUseOriginalAuthorization(meta, customBaseUrl != null);

    final LLMAdapter? adapter = channelAdapterMapper[modelInfo.adapter];
    if (adapter == null) {
      throw AdapterNotFoundException(model);
    }

    final String originalApiKeyWithBearer = requestHeaders["Authorization"] ?? "";
    meta = initOriginalApiKeyWithBearer(meta, originalApiKeyWithBearer);
    if(adapterKeyPools != null && meta.useOriginalAuthorization != true) {
      final IndexItem<ApiKey> indexApiKey = adapterKeyPools![meta.adapterName]!.fetch();
      meta = initIndexApiKey(meta, indexApiKey);
    }
    meta = initRelayMode(meta, requestPath);

    adapter.init(meta);

    return PreparedGatewayRequest(
      adapter: adapter,
      meta: meta,
    );
  }

  ModelInfo? _selectModel(String model) {
    final List<LLMModel> models = modelMapping.models;
    for(final LLMModel llmModel in models) {
      for(final String name in llmModel.names) {
        if(name == model) {
          return ModelInfo(name: name, adapter: llmModel.adapter, baseUrl: llmModel.baseUrl);
        }
      }
    }
    return null;
  }

  ModelInfo? _resolveModelInfo(String model, ModelInfo? mappedModelInfo, String? customBaseUrl, String? customAdapter) {
    if(customBaseUrl == null && customAdapter == null) {
      return mappedModelInfo;
    }

    String adapterName;
    if(customAdapter != null) {
      adapterName = customAdapter.toLowerCase();
    } else if(mappedModelInfo != null) {
      adapterName = mappedModelInfo.adapter;
    } else {
      adapterName = "openai";
    }

    if(!channelAdapterMapper.containsKey(adapterName)) {
      throw UnsupportedRequestException("Adapter `$adapterName` is not supported.");
    }

    final String resolvedBaseUrl = customBaseUrl ?? mappedModelInfo?.baseUrl ?? "";
    if(resolvedBaseUrl.isEmpty) {
      throw UnsupportedRequestException("A valid `base_url` or mapped provider base URL is required for adapter `$adapterName`.");
    }

    return ModelInfo(
      name: model,
      adapter: adapterName,
      baseUrl: resolvedBaseUrl,
    );
  }

  String? _readString(Map<String, dynamic> data, List<String> keys) {
    for(final String key in keys) {
      final dynamic value = data[key];
      if(value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  Map<String, dynamic> _sanitizeRequestData(Map<String, dynamic> data) {
    final Map<String, dynamic> requestData = Map<String, dynamic>.from(data);
    requestData.remove("base_url");
    requestData.remove("baseUrl");
    requestData.remove("adapter");
    requestData.remove("channel");
    return requestData;
  }
}
