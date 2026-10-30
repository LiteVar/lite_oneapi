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
  bool isCustomBaseUrl = false;
  String? endpoint;
  bool useOriginalAuthorization = false;
  late String originalApiKeyWithBearer;
  late IndexApiKey? indexApiKey;
  late RelayMode mode;

  Meta(
      {required this.model, required this.isStream, required this.requestBody});
}

typedef HandleMeta<T> = Meta Function(Meta meta, T data);

Meta initModelInfo(Meta meta, ModelInfo data,
    {bool isCustomBaseUrl = false, String? endpoint}) {
  meta.adapterName = data.adapter;
  meta.baseUrl = data.baseUrl;
  meta.isCustomBaseUrl = isCustomBaseUrl;
  meta.endpoint = endpoint;
  logger.log(LogModule.api, "initModelInfo",
      detail: "adapter: ${data.adapter}, baseUrl: ${data.baseUrl}",
      level: Level.FINEST);
  return meta;
}

HandleMeta<bool> initUseOriginalAuthorization = (Meta meta, bool data) {
  meta.useOriginalAuthorization = data;
  logger.log(LogModule.api, "initUseOriginalAuthorization",
      detail: "useOriginalAuthorization: $data", level: Level.FINEST);
  return meta;
};

HandleMeta<String> initOriginalApiKeyWithBearer = (Meta meta, String data) {
  meta.originalApiKeyWithBearer = data;
  logger.log(LogModule.api, "initOriginalApiKeyWithBearer",
      detail: "originalApiKeyWithBearer: ${data}", level: Level.FINEST);
  return meta;
};

HandleMeta<IndexItem<ApiKey>> initIndexApiKey =
    (Meta meta, IndexItem<ApiKey> data) {
  meta.indexApiKey =
      IndexApiKey(id: data.id, type: data.item.type, apiKey: data.item.apiKey);
  logger.log(LogModule.api, "initIndexApiKey",
      detail: "id: ${data.id}, type: ${data.item.type}", level: Level.FINEST);
  return meta;
};

HandleMeta<String> initRelayMode = (Meta meta, String path) {
  final String normalizedPath = path.startsWith('/') ? path : '/$path';
  RelayMode relayMode = getByPath(normalizedPath);
  meta.mode = relayMode;
  logger.log(LogModule.api, "initRelayMode",
      detail: "relayMode: $relayMode", level: Level.FINEST);
  return meta;
};
