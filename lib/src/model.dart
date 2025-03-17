import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';

part 'model.g.dart';

@JsonSerializable(createToJson: false)
class ModelMapping {
  List<LLMModel> models;

  ModelMapping({required this.models});

  factory ModelMapping.fromJson(Map<String, dynamic> json) => _$ModelMappingFromJson(json);
}

@JsonSerializable(createToJson: false)
class LLMModel {
  List<String> names;
  String adapter;
  String baseUrl;

  LLMModel({required this.names, required this.adapter, required this.baseUrl});

  factory LLMModel.fromJson(Map<String, dynamic> json) => _$LLMModelFromJson(json);
}


@JsonSerializable(createToJson: false)
class Config {
  late String version;
  late Server server;
  late Log log;

  Config({required this.server, required this.log, this.version = "0.0.0"});

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
}

@JsonSerializable(createToJson: false)
class Server {
  late String ip;
  late int port;

  Server({this.ip = "0.0.0.0", this.port = 9517});

  factory Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);
}

class Log {
  late Level level;

  Log({this.level = Level.INFO});

  factory Log.fromJson(Map<String, dynamic> json) {
    String levelString = json['level'] as String;
    return Log(level: _convertToLevel(levelString));
  }

  static Level _convertToLevel(String level) {
    switch (level) {
      case "ALL":
        return Level.ALL;
      case "FINEST":
        return Level.FINEST;
      case "FINER":
        return Level.FINER;
      case "FINE":
        return Level.FINE;
      case "CONFIG":
        return Level.CONFIG;
      case "INFO":
        return Level.INFO;
      case "WARNING":
        return Level.WARNING;
      case "SEVERE":
        return Level.SEVERE;
      case "SHOUT":
        return Level.SHOUT;
      case "OFF":
        return Level.OFF;
      default:
        return Level.INFO;
    }
  }
}

@JsonSerializable(createToJson: false)
class Env {
  List<String> apiKeys;
  Map<String, List<ApiKey>> adapterKeys;

  Env({this.apiKeys = const [], this.adapterKeys = const {}});

  factory Env.fromJson(Map<String, dynamic> json) => _$EnvFromJson(json);
}

enum ApiKeyType { basic, bearer, none}

@JsonSerializable(createToJson: false)
class ApiKey {
  ApiKeyType type;
  String apiKey;

  ApiKey({required this.type, required this.apiKey});

  factory ApiKey.fromJson(Map<String, dynamic> json) => _$ApiKeyFromJson(json);
}