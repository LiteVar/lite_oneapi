import 'package:json_annotation/json_annotation.dart';

part 'chat_completions_chunk.g.dart';

/// https://docs.newllm.com/docs/api-reference/chat-streaming/streaming

@JsonSerializable()
class ChatCompletionsChunk {
  List<Choice> choices;
  int created;
  String id;
  String model;
  String object;  /// `chat.completion.chunk`
  @JsonKey(includeIfNull: false) String? service_tier;
  String system_fingerprint;
  @JsonKey(includeIfNull: false) Usage? usage;

  ChatCompletionsChunk({
    required this.id,
    required this.choices,
    required this.created,
    required this.model,
    required this.object,
    this.service_tier,
    required this.system_fingerprint,
    this.usage,
  });

  factory ChatCompletionsChunk.fromJson(Map<String, dynamic> json) => _$ChatCompletionsChunkFromJson(json);

  Map<String, dynamic> toJson() => _$ChatCompletionsChunkToJson(this);
}

@JsonSerializable()
class Choice {
  Delta delta;
  @JsonKey(includeIfNull: false) String? finish_reason; /// `stop`, `length`, `content_filter`, `tool_calls`
  String index;
  @JsonKey(includeIfNull: false) Logprobs? logprobs;

  Choice({required this.delta, required this.finish_reason, required this.index, this.logprobs});

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

@JsonSerializable()
class Logprobs {
  @JsonKey(includeIfNull: false) List<Logprob>? content;
  @JsonKey(includeIfNull: false) List<Logprob>? refusal;

  Logprobs({this.content, this.refusal});

  factory Logprobs.fromJson(Map<String, dynamic> json) => _$LogprobsFromJson(json);

  Map<String, dynamic> toJson() => _$LogprobsToJson(this);
}

@JsonSerializable()
class Logprob {
  @JsonKey(includeIfNull: false) List<int>? bytes;
  int logprob;
  String token;
  List<TopLogrob> top_logprobs;

  Logprob({this.bytes, required this.logprob, required this.token, required this.top_logprobs});

  factory Logprob.fromJson(Map<String, dynamic> json) => _$LogprobFromJson(json);

  Map<String, dynamic> toJson() => _$LogprobToJson(this);
}

@JsonSerializable()
class TopLogrob {
  @JsonKey(includeIfNull: false) List<int>? bytes;
  int logprob;
  String token;
  List<TopLogrob> top_logprobs;

  TopLogrob({this.bytes, required this.logprob, required this.token, required this.top_logprobs});

  factory TopLogrob.fromJson(Map<String, dynamic> json) => _$TopLogrobFromJson(json);

  Map<String, dynamic> toJson() => _$TopLogrobToJson(this);
}

@JsonSerializable()
class Usage {
  int completion_tokens;
  int prompt_tokens;
  int total_tokens;

  Usage({required this.completion_tokens, required this.prompt_tokens, required this.total_tokens});

  factory Usage.fromJson(Map<String, dynamic> json) => _$UsageFromJson(json);

  Map<String, dynamic> toJson() => _$UsageToJson(this);
}
