import 'package:json_annotation/json_annotation.dart';

part 'chat_completions_chunk.g.dart';

/// https://help.aliyun.com/zh/model-studio/developer-reference/use-qwen-by-calling-api#f0b9c155ad0e0

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ChatCompletionsChunk {
  String id;
  List<Choice> choices;
  int created;
  String model;
  String object;  /// `chat.completion.chunk`
  String? service_tier;  /// null
  String? system_fingerprint; /// null
  Usage? usage;

  ChatCompletionsChunk({
    required this.id,
    required this.choices,
    required this.created,
    required this.model,
    required this.object,
    this.service_tier,
    this.system_fingerprint,
    this.usage,
  });

  factory ChatCompletionsChunk.fromJson(Map<String, dynamic> json) => _$ChatCompletionsChunkFromJson(json);

  Map<String, dynamic> toJson() => _$ChatCompletionsChunkToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Choice {
  Delta delta;
  String? finish_reason; /// `stop`, `null`, `length`, `tool_calls`
  String index;

  Choice({required this.delta, required this.finish_reason, required this.index});

  factory Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$ChoiceToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Delta {
  String content;
  String reasoning_content;
  FunctionCalledModel? function_call;  /// null
  String? refusal; /// null
  String role;  /// `assistant`
  List<ToolCall>? tools_calls;

  Delta({required this.content, required this.reasoning_content, required this.role});

  factory Delta.fromJson(Map<String, dynamic> json) => _$DeltaFromJson(json);

  Map<String, dynamic> toJson() => _$DeltaToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class FunctionCalledModel {
  String name;
  Map<String, dynamic> arguments;

  FunctionCalledModel({required this.name, required this.arguments});

  factory FunctionCalledModel.fromJson(Map<String, dynamic> json) => _$FunctionCalledModelFromJson(json);

  Map<String, dynamic> toJson() => _$FunctionCalledModelToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ToolCall {
  String id;
  String type;
  FunctionCalledModel function;

  ToolCall({required this.id, required this.type, required this.function});

  factory ToolCall.fromJson(Map<String, dynamic> json) => _$ToolCallFromJson(json);

  Map<String, dynamic> toJson() => _$ToolCallToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Usage {
  int completion_tokens;
  int prompt_tokens;
  int total_tokens;
  CompletionTokensDetails? completion_tokens_details;
  PromptTokensDetails prompt_tokens_details;

  Usage({required this.completion_tokens, required this.prompt_tokens, required this.total_tokens, required this.completion_tokens_details, required this.prompt_tokens_details});

  factory Usage.fromJson(Map<String, dynamic> json) => _$UsageFromJson(json);

  Map<String, dynamic> toJson() => _$UsageToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class CompletionTokensDetails {
  int text_tokens;

  CompletionTokensDetails({required this.text_tokens});

  factory CompletionTokensDetails.fromJson(Map<String, dynamic> json) => _$CompletionTokensDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$CompletionTokensDetailsToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class PromptTokensDetails {
  int? audio_tokens;
  int? text_tokens;
  int? video_tokens;
  int? image_tokens;
  int cached_tokens;

  PromptTokensDetails({this.audio_tokens, this.text_tokens, this.video_tokens, this.image_tokens, required this.cached_tokens});

  factory PromptTokensDetails.fromJson(Map<String, dynamic> json) => _$PromptTokensDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$PromptTokensDetailsToJson(this);
}