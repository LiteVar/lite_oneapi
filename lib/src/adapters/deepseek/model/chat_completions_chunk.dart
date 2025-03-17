import 'package:json_annotation/json_annotation.dart';

part 'chat_completions_chunk.g.dart';

/// https://api-docs.deepseek.com/zh-cn/api/create-chat-completion#responses

@JsonSerializable()
class ChatCompletionsChunk {
  String id;
  List<Choice> choices;
  int created;
  String model;
  String system_fingerprint;
  String object;  /// `chat.completion.chunk`

  ChatCompletionsChunk({
    required this.id,
    required this.choices,
    required this.created,
    required this.model,
    required this.system_fingerprint,
    required this.object,
  });

  factory ChatCompletionsChunk.fromJson(Map<String, dynamic> json) => _$ChatCompletionsChunkFromJson(json);

  Map<String, dynamic> toJson() => _$ChatCompletionsChunkToJson(this);
}

@JsonSerializable()
class Choice {
  Delta delta;
  @JsonKey(includeIfNull: false) String? finish_reason; /// `stop`, `length`, `content_filter`, `tool_calls`
  String index;

  Choice({required this.delta, required this.finish_reason, required this.index});

  factory Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$ChoiceToJson(this);
}

@JsonSerializable()
class Delta {
  String content;
  String reasoning_content;
  String role;  /// `assistant`

  Delta({required this.content, required this.reasoning_content, required this.role});

  factory Delta.fromJson(Map<String, dynamic> json) => _$DeltaFromJson(json);

  Map<String, dynamic> toJson() => _$DeltaToJson(this);
}