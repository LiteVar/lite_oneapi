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
    String? model = data["model"];
    logger.log(LogModule.api, "Request handle", detail: "model: $model");

    try {
      if (model == null) return Response.notFound(AdapterNotFoundException("NULL").toJson());

      Meta meta = Meta(model: model, isStream: data["stream"] ?? false, requestBody: payload);

      ModelInfo? modelInfo = _selectModel(model);
      if (modelInfo == null) throw AdapterNotFoundException(model);
      meta = initModelInfo(meta, modelInfo);

      LLMAdapter? adapter = channelAdapterMapper[modelInfo.adapter];
      if (adapter == null) throw AdapterNotFoundException(model);
      IndexItem<ApiKey> indexApiKey = adapterKeyPools[meta.adapterName]!.fetch();
      meta = initIndexApiKey(meta, indexApiKey);

      meta = initRelayMode(meta, request.url.path);

      adapter.init(meta);

      return adapter.doRequest(request, meta);
    } on AdapterNotFoundException catch(e) {
      return Response.notFound(e.toString());
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
}
