import 'dart:convert';
import 'dart:io';
import 'adapters/adapter.dart';
import 'adapters/chat_completions/anthropic/adapter.dart';
import 'adapters/chat_completions/deepseek/adapter.dart';
import 'adapters/chat_completions/doubao/adapter.dart';
import 'adapters/chat_completions/glm/adapter.dart';
import 'adapters/chat_completions/hunyuan/adapter.dart';
import 'adapters/chat_completions/kimi/adapter.dart';
import 'adapters/chat_completions/mimo/adapter.dart';
import 'adapters/chat_completions/minimax/adapter.dart';
import 'adapters/chat_completions/openai/adapter.dart';
import 'adapters/chat_completions/qwen/adapter.dart';
import 'adapters/messages/anthropic/adapter.dart';
import 'adapters/messages/deepseek/adapter.dart';
import 'adapters/messages/doubao/adapter.dart';
import 'adapters/messages/glm/adapter.dart';
import 'adapters/messages/hunyuan/adapter.dart';
import 'adapters/messages/kimi/adapter.dart';
import 'adapters/messages/minimax/adapter.dart';
import 'adapters/messages/qwen/adapter.dart';
import 'adapters/responses/deepseek/adapter.dart';
import 'adapters/responses/doubao/adapter.dart';
import 'adapters/responses/hunyuan/adapter.dart';
import 'adapters/responses/kimi/adapter.dart';
import 'adapters/responses/openai/adapter.dart';
import 'adapters/responses/qwen/adapter.dart';
import 'model.dart';
import 'utils/dir.dart';
import 'utils/pool.dart';

Map<String, LLMAdapter> channelAdapterMapper = {
  "openai": OpenAIAdapter(),
  "anthropic": AnthropicChatCompletionsAdapter(),
  "deepseek": DeepSeekAdapter(),
  "doubao": DoubaoAdapter(),
  "glm": GLMAdapter(),
  "hunyuan": HunyuanAdapter(),
  "kimi": KimiAdapter(),
  "mimo": MimoAdapter(),
  "minimax": MiniMaxAdapter(),
  "qwen": QwenAdapter(),

  /// Add other adapters
};

/// Independent OpenAI Responses protocol adapters. Each one speaks the
/// Responses schema directly to the corresponding upstream endpoint.
Map<String, LLMAdapter> responsesAdapterMapper = {
  "openai": OpenAIResponsesAdapter(),
  "deepseek": DeepSeekResponsesAdapter(),
  "qwen": QwenResponsesAdapter(),
  "kimi": KimiResponsesAdapter(),
  "doubao": DoubaoResponsesAdapter(),
  "hunyuan": HunyuanResponsesAdapter(),
};

/// Independent Anthropic Messages protocol adapters.
Map<String, LLMAdapter> messagesAdapterMapper = {
  "anthropic": AnthropicMessagesAdapter(),
  "deepseek": DeepSeekMessagesAdapter(),
  "qwen": QwenMessagesAdapter(),
  "glm": GLMMessagesAdapter(),
  "kimi": KimiMessagesAdapter(),
  "minimax": MiniMaxMessagesAdapter(),
  "doubao": DoubaoMessagesAdapter(),
  "hunyuan": HunyuanMessagesAdapter(),
};

final Config config = initConfig();
final ModelMapping modelMapping = initModelMapping();
final Env? env = initEnv();
final Map<String, Pool<ApiKey>>? adapterKeyPools = initApiKeyPool();

ModelMapping initModelMapping() {
  String exeDir = Dir.executableDir();
  String modelMappingFilePath =
      '$exeDir${Platform.pathSeparator}model_mapping.json';
  String modelMappingJsonString = File(modelMappingFilePath).readAsStringSync();
  final Map<String, dynamic> modelMappingJson =
      jsonDecode(modelMappingJsonString);
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

Env? initEnv() {
  try {
    String exeDir = Dir.executableDir();
    String envFilePath = '$exeDir${Platform.pathSeparator}env.json';
    String envJsonString = File(envFilePath).readAsStringSync();
    final Map<String, dynamic> configJson = jsonDecode(envJsonString);
    final Env env = Env.fromJson(configJson);
    return env;
  } catch (e) {
    return null;
  }
}

Map<String, Pool<ApiKey>>? initApiKeyPool() {
  Map<String, Pool<ApiKey>> pools = {};
  if (env != null) {
    env!.adapterKeys.forEach((key, value) {
      pools[key] = Pool(value);
    });
    return pools;
  }
  return null;
}
