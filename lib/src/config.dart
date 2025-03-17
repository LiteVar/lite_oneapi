import 'dart:convert';
import 'dart:io';
import 'adapters/adapter.dart';
import 'adapters/deepseek/adapter.dart';
import 'adapters/openai/adapter.dart';
import 'adapters/qwen/adapter.dart';
import 'model.dart';
import 'utils/dir.dart';
import 'utils/pool.dart';

Map<String, LLMAdapter> channelAdapterMapper = {
  "openai": OpenAIAdapter(),
  "deepseek": DeepSeekAdapter(),
  "qwen": QwenAdapter(),
  /// Add other adapters
};

final Config config = initConfig();
final ModelMapping modelMapping = initModelMapping();
final Env env = initEnv();
final Map<String, Pool<ApiKey>> adapterKeyPools = initApiKeyPool();

ModelMapping initModelMapping() {
  String exeDir = Dir.executableDir();
  String modelMappingFilePath = '$exeDir${Platform.pathSeparator}model_mapping.json';
  String modelMappingJsonString = File(modelMappingFilePath).readAsStringSync();
  final Map<String, dynamic> modelMappingJson = jsonDecode(modelMappingJsonString);
  final ModelMapping modelMapping = ModelMapping.fromJson(modelMappingJson);
  return modelMapping;
}

Config initConfig() {
  String exeDir = Dir.executableDir();
  String configFilePath = '$exeDir${Platform.pathSeparator}config.json';
  String configJsonString = File(configFilePath).readAsStringSync();
  final Map<String, dynamic> configJson = jsonDecode(configJsonString);
  final Config config = Config.fromJson(configJson);
  return config;
}

Env initEnv() {
  try {
    String exeDir = Dir.executableDir();
    String envFilePath = '$exeDir${Platform.pathSeparator}env.json';
    String envJsonString = File(envFilePath).readAsStringSync();
    final Map<String, dynamic> configJson = jsonDecode(envJsonString);
    final Env env = Env.fromJson(configJson);
    return env;
  } catch(e) {
    return Env();
  }
}

Map<String, Pool<ApiKey>> initApiKeyPool() {
  Map<String, Pool<ApiKey>> pools = {};
  env.adapterKeys.forEach((key, value) {
    pools[key] = Pool(value);
  });
  return pools;
}