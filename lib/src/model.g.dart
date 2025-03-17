// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelMapping _$ModelMappingFromJson(Map<String, dynamic> json) => ModelMapping(
  models:
      (json['models'] as List<dynamic>)
          .map((e) => LLMModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

LLMModel _$LLMModelFromJson(Map<String, dynamic> json) => LLMModel(
  names: (json['names'] as List<dynamic>).map((e) => e as String).toList(),
  adapter: json['adapter'] as String,
  baseUrl: json['baseUrl'] as String,
);

Config _$ConfigFromJson(Map<String, dynamic> json) => Config(
  server: Server.fromJson(json['server'] as Map<String, dynamic>),
  log: Log.fromJson(json['log'] as Map<String, dynamic>),
  version: json['version'] as String? ?? "0.0.0",
);

Server _$ServerFromJson(Map<String, dynamic> json) => Server(
  ip: json['ip'] as String? ?? "0.0.0.0",
  port: (json['port'] as num?)?.toInt() ?? 9517,
);

Env _$EnvFromJson(Map<String, dynamic> json) => Env(
  apiKeys:
      (json['apiKeys'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  adapterKeys:
      (json['adapterKeys'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map((e) => ApiKey.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ) ??
      const {},
);

ApiKey _$ApiKeyFromJson(Map<String, dynamic> json) => ApiKey(
  type: $enumDecode(_$ApiKeyTypeEnumMap, json['type']),
  apiKey: json['apiKey'] as String,
);

const _$ApiKeyTypeEnumMap = {
  ApiKeyType.basic: 'basic',
  ApiKeyType.bearer: 'bearer',
  ApiKeyType.none: 'none',
};
