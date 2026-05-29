import 'dart:convert';
import 'package:lite_oneapi/lite_oneapi.dart';
import 'package:lite_oneapi/src/adapters/adapter.dart';
import 'package:lite_oneapi/src/adapters/exception.dart';
import 'package:lite_oneapi/src/api/meta.dart';
import 'package:lite_oneapi/src/model.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import '../adapters/model.dart';
import '../utils/pool.dart';

final OneApiController oneApiController = OneApiController();

class OneApiController {
  Future<Response> handle(Request request) async {
    final String payload = await request.readAsString();
    logger.log(LogModule.api, "Request handle", detail: payload, level: Level.FINEST);

    final Map<String, dynamic> data = jsonDecode(payload);
    final String? customBaseUrl = _readString(data, ["base_url", "baseUrl"]);
    final String? customAdapter = _readString(data, ["adapter", "channel"]);
    final Map<String, dynamic> requestData = _sanitizeRequestData(data);
    String? model = data["model"];
    logger.log(LogModule.api, "Request handle", detail: "model: $model");

    try {
      if (model == null) return Response.notFound(AdapterNotFoundException("NULL").toJson());

      Meta meta = Meta(
        model: model,
        isStream: data["stream"] ?? false,
        requestBody: jsonEncode(requestData),
      );

      ModelInfo? mappedModelInfo = _selectModel(model);
      ModelInfo? modelInfo = _resolveModelInfo(model, mappedModelInfo, customBaseUrl, customAdapter);
      if (modelInfo == null) throw AdapterNotFoundException(model);
      meta = initModelInfo(meta, modelInfo);
      meta = initUseOriginalAuthorization(meta, customBaseUrl != null);

      LLMAdapter? adapter = channelAdapterMapper[modelInfo.adapter];
      if (adapter == null) throw AdapterNotFoundException(model);

      String originalApiKeyWithBearer = request.headers["Authorization"]??"";
      meta = initOriginalApiKeyWithBearer(meta, originalApiKeyWithBearer);
      if(adapterKeyPools != null && meta.useOriginalAuthorization != true) {
        IndexItem<ApiKey> indexApiKey = adapterKeyPools![meta.adapterName]!.fetch();
        meta = initIndexApiKey(meta, indexApiKey);
      }
      meta = initRelayMode(meta, request.url.path);

      adapter.init(meta);

      return adapter.doRequest(request, meta);
    } on AdapterNotFoundException catch(e) {
      return Response.notFound(e.toString());
    } on UnsupportedRequestException catch(e) {
      return Response(400, body: jsonEncode(e.toJson()), headers: {"content-type": "application/json"});
    } on PoolExhaustedException catch(e) {
      return Response.internalServerError(body: "Adapter ApiKey error: " + e.toString());
    }
  }

  ModelInfo? _selectModel(String model) {
    List<LLMModel> models = modelMapping.models;
    for(LLMModel llmModel in models) {
      for(String name in llmModel.names) {
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
    for(final key in keys) {
      final value = data[key];
      if(value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  Map<String, dynamic> _sanitizeRequestData(Map<String, dynamic> data) {
    final requestData = Map<String, dynamic>.from(data);
    requestData.remove("base_url");
    requestData.remove("baseUrl");
    requestData.remove("adapter");
    requestData.remove("channel");
    return requestData;
  }
}
