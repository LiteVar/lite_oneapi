// ignore_for_file: implementation_imports

import 'dart:convert';

import 'package:dart_openai_sdk/dart_openai_sdk.dart'
    show
        OpenAIChatCompletionChoiceMessageModel,
        OpenAIChatCompletionModel,
        OpenAIStreamChatCompletionModel,
        OpenAIToolModel;
import 'package:dart_openai_sdk/src/instance/chat/chat.dart' show OpenAIChat;
import 'package:http/http.dart' as http;

import '../../core/gateway_service.dart';
import '../builder/chat_request.dart';
import '../config/client_config.dart';
import '../mapper/chat_response.dart';
import '../mapper/chat_stream_response.dart';

class LiteOneApiChat implements OpenAIChat {
  final LiteOneApiClientConfig config;
  final LiteOneApiGatewayService gatewayService;

  const LiteOneApiChat({
    required this.config,
    required this.gatewayService,
  });

  @override
  String get endpoint => 'chat/completions';

  @override
  Future<OpenAIChatCompletionModel> create({
    required String model,
    required List<OpenAIChatCompletionChoiceMessageModel> messages,
    List<OpenAIToolModel>? tools,
    Object? toolChoice,
    double? temperature,
    double? topP,
    int? n,
    Object? stop,
    int? maxTokens,
    double? presencePenalty,
    double? frequencyPenalty,
    Map<String, dynamic>? logitBias,
    String? user,
    Object? responseFormat,
    int? seed,
    bool? logprobs,
    int? topLogprobs,
    http.Client? client,
    String? reasoningEffort,
    bool? enableThinking,
  }) async {
    final Map<String, dynamic> requestBody = LiteOneApiChatRequestBuilder(
      config: config,
      model: model,
      messages: messages,
      tools: tools,
      toolChoice: toolChoice,
      temperature: temperature,
      topP: topP,
      n: n,
      stop: stop,
      maxTokens: maxTokens,
      presencePenalty: presencePenalty,
      frequencyPenalty: frequencyPenalty,
      logitBias: logitBias,
      user: user,
      responseFormat: responseFormat,
      seed: seed,
      logprobs: logprobs,
      topLogprobs: topLogprobs,
      reasoningEffort: reasoningEffort,
      enableThinking: enableThinking,
      stream: false,
    ).build();

    final response = await gatewayService.handleJsonRequest(
      payload: jsonEncode(requestBody),
      requestPath: config.chatCompletionsPath,
      requestHeaders: _buildHeaders(),
    );

    final String body = await response.readAsString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('lite_oneapi chat.create failed (${response.statusCode}): $body');
    }
    return LiteOneApiChatResponseMapper.fromJsonString(body);
  }

  @override
  Stream<OpenAIStreamChatCompletionModel> createStream({
    required String model,
    required List<OpenAIChatCompletionChoiceMessageModel> messages,
    List<OpenAIToolModel>? tools,
    Object? toolChoice,
    double? temperature,
    double? topP,
    int? n,
    Object? stop,
    int? maxTokens,
    double? presencePenalty,
    double? frequencyPenalty,
    Map<String, dynamic>? logitBias,
    Object? responseFormat,
    int? seed,
    String? user,
    http.Client? client,
    Map<String, dynamic>? streamOptions,
    String? reasoningEffort,
    bool? enableThinking,
  }) async* {
    final Map<String, dynamic> requestBody = LiteOneApiChatRequestBuilder(
      config: config,
      model: model,
      messages: messages,
      tools: tools,
      toolChoice: toolChoice,
      temperature: temperature,
      topP: topP,
      n: n,
      stop: stop,
      maxTokens: maxTokens,
      presencePenalty: presencePenalty,
      frequencyPenalty: frequencyPenalty,
      logitBias: logitBias,
      user: user,
      responseFormat: responseFormat,
      seed: seed,
      streamOptions: streamOptions,
      reasoningEffort: reasoningEffort,
      enableThinking: enableThinking,
      stream: true,
    ).build();

    final response = await gatewayService.handleJsonRequest(
      payload: jsonEncode(requestBody),
      requestPath: config.chatCompletionsPath,
      requestHeaders: _buildHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String body = await response.readAsString();
      throw StateError('lite_oneapi chat.createStream failed (${response.statusCode}): $body');
    }

    yield* LiteOneApiChatStreamResponseMapper.fromSseByteStream(response.read());
  }

  @override
  Stream<OpenAIStreamChatCompletionModel> createRemoteFunctionStream({
    required String model,
    required List<OpenAIChatCompletionChoiceMessageModel> messages,
    List<OpenAIToolModel>? tools,
    Object? toolChoice,
    double? temperature,
    double? topP,
    int? n,
    Object? stop,
    int? maxTokens,
    double? presencePenalty,
    double? frequencyPenalty,
    Map<String, dynamic>? logitBias,
    String? user,
    http.Client? client,
    Object? responseFormat,
    int? seed,
    String? reasoningEffort,
    bool? enableThinking,
  }) {
    return createStream(
      model: model,
      messages: messages,
      tools: tools,
      toolChoice: toolChoice,
      temperature: temperature,
      topP: topP,
      n: n,
      stop: stop,
      maxTokens: maxTokens,
      presencePenalty: presencePenalty,
      frequencyPenalty: frequencyPenalty,
      logitBias: logitBias,
      responseFormat: responseFormat,
      seed: seed,
      user: user,
      client: client,
      reasoningEffort: reasoningEffort,
      enableThinking: enableThinking,
    );
  }

  Map<String, String> _buildHeaders() {
    final Map<String, String> headers = <String, String>{...config.headers};
    if (config.apiKey != null && config.apiKey!.isNotEmpty) {
      headers.putIfAbsent('Authorization', () => 'Bearer ${config.apiKey!}');
    }
    headers.putIfAbsent('Content-Type', () => 'application/json');
    return headers;
  }
}
