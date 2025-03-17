import 'package:logging/logging.dart';

import '../define.dart';
import '../adapters/model.dart';
import '../model.dart';
import '../utils/pool.dart';
import '../utils/logger.dart';

class Meta {
  String model;
  bool isStream;
  String requestBody;

  late String adapterName;
  late String baseUrl;
  late IndexApiKey indexApiKey;
  late RelayMode mode;

  Meta({required this.model, required this.isStream, required this.requestBody});
}

typedef HandleMeta<T> = Meta Function(Meta meta, T data);

HandleMeta<ModelInfo> initModelInfo = (Meta meta, ModelInfo data) {
  meta.adapterName = data.adapter;
  meta.baseUrl = data.baseUrl;
  logger.log(LogModule.api, "initModelInfo", detail: "adapter: ${data.adapter}, baseUrl: ${data.baseUrl}", level: Level.FINEST);
  return meta;
};

HandleMeta<IndexItem<ApiKey>> initIndexApiKey = (Meta meta, IndexItem<ApiKey> data) {
  meta.indexApiKey = IndexApiKey(id: data.id, type: data.item.type, apiKey: data.item.apiKey);
  logger.log(LogModule.api, "initIndexApiKey", detail: "id: ${data.id}, type: ${data.item.type}", level: Level.FINEST);
  return meta;
};

HandleMeta<String> initRelayMode = (Meta meta, String path) {
  RelayMode relayMode = getByPath("/$path");
  meta.mode = relayMode;
  logger.log(LogModule.api, "initRelayMode", detail: "relayMode: $relayMode", level: Level.FINEST);
  return meta;
};