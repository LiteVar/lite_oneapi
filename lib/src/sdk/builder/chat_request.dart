// ignore_for_file: implementation_imports

import 'package:dart_openai_sdk/dart_openai_sdk.dart'
    show OpenAIChatCompletionChoiceMessageModel, OpenAIToolModel;

import '../config/client_config.dart';
import 'response_format_mapper.dart';

class LiteOneApiChatRequestBuilder {
  final LiteOneApiClientConfig config;
  final String model;
  final List<OpenAIChatCompletionChoiceMessageModel> messages;
  final List<OpenAIToolModel>? tools;
  final Object? toolChoice;
  final double? temperature;
  final double? topP;
  final int? n;
  final Object? stop;
  final int? maxTokens;
  final double? presencePenalty;
  final double? frequencyPenalty;
  final Map<String, dynamic>? logitBias;
  final String? user;
  final Object? responseFormat;
  final int? seed;
  final bool? logprobs;
  final int? topLogprobs;
  final Map<String, dynamic>? streamOptions;
  final String? reasoningEffort;
  final bool? enableThinking;
  final bool stream;

  const LiteOneApiChatRequestBuilder({
    required this.config,
    required this.model,
    required this.messages,
    this.tools,
    this.toolChoice,
    this.temperature,
    this.topP,
    this.n,
    this.stop,
    this.maxTokens,
    this.presencePenalty,
    this.frequencyPenalty,
    this.logitBias,
    this.user,
    this.responseFormat,
    this.seed,
    this.logprobs,
    this.topLogprobs,
    this.streamOptions,
    this.reasoningEffort,
    this.enableThinking,
    required this.stream,
  });

  Map<String, dynamic> build() {
    return {
      "model": model,
      if (stream) "stream": true,
      "messages": messages.map((message) => message.toMap()).toList(growable: false),
      if (tools != null) "tools": tools!.map((tool) => tool.toMap()).toList(growable: false),
      if (toolChoice != null) "tool_choice": toolChoice,
      if (temperature != null) "temperature": temperature,
      if (topP != null) "top_p": topP,
      if (n != null) "n": n,
      if (stop != null) "stop": stop,
      if (maxTokens != null) "max_completion_tokens": maxTokens,
      if (presencePenalty != null) "presence_penalty": presencePenalty,
      if (frequencyPenalty != null) "frequency_penalty": frequencyPenalty,
      if (logitBias != null) "logit_bias": logitBias,
      if (user != null) "user": user,
      if (responseFormat != null) "response_format": LiteOneApiResponseFormatMapper.map(responseFormat),
      if (seed != null) "seed": seed,
      if (logprobs != null) "logprobs": logprobs,
      if (topLogprobs != null) "top_logprobs": topLogprobs,
      if (streamOptions != null && streamOptions!.isNotEmpty) "stream_options": streamOptions,
      if (reasoningEffort != null) "reasoning_effort": reasoningEffort,
      if (enableThinking != null) "enable_thinking": enableThinking,
      if (config.baseUrl != null && config.baseUrl!.isNotEmpty) "base_url": config.baseUrl,
      if (config.adapter != null && config.adapter!.isNotEmpty) "adapter": config.adapter,
    };
  }
}
