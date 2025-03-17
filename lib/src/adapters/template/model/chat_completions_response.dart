import 'package:json_annotation/json_annotation.dart';

part 'chat_completions_response.g.dart';

/// https://docs.newllm.com/docs/api-reference/chat/object

@JsonSerializable()
class ChatCompletionsResponse {
  List<Choice> choices;
  int created;
  String id;
  String model;
  String object;  /// `chat.completion`
  @JsonKey(includeIfNull: false) String? service_tier;
  String system_fingerprint;
  Usage usage;

  ChatCompletionsResponse({
    required this.choices,
    required this.created,
    required this.id,
    required this.model,
    required this.object,
    this.service_tier,
    required this.system_fingerprint,
    required this.usage,
  });

  factory ChatCompletionsResponse.fromJson(Map<String, dynamic> json) => _$ChatCompletionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatCompletionsResponseToJson(this);
}

@JsonSerializable()
class Choice {
  String finish_reason;
  String index;
  @JsonKey(includeIfNull: false) Logprobs? logprobs;
  Message message;

  Choice({required this.finish_reason, required this.index, this.logprobs, required this.message});

  factory Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$ChoiceToJson(this);
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
class Message {
  @JsonKey(includeIfNull: false) String? content;
  @JsonKey(includeIfNull: false) String? refusal;
  String role;
  List<Annotation> annotations;
  @JsonKey(includeIfNull: false) Audio? audio;
  @Deprecated('Deprecated and replaced by tool_calls.') @JsonKey(includeIfNull: false) FunctionCalledModel? function_call;
  @JsonKey(includeIfNull: false) String? name;
  @JsonKey(includeIfNull: false) List<ToolCall>? tool_calls;

  Message({this.content, this.refusal, required this.role, required this.annotations, this.audio, this.function_call, this.name, this.tool_calls});

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class Annotation {
  String type;  /// `url_citation`
  UrlCitation url_citation;

  Annotation({required this.type, required this.url_citation});

  factory Annotation.fromJson(Map<String, dynamic> json) => _$AnnotationFromJson(json);

  Map<String, dynamic> toJson() => _$AnnotationToJson(this);
}

@JsonSerializable()
class Audio {
  String data;
  int expires_at;
  String id;
  String transcript;

  Audio({required this.data, required this.expires_at, required this.id, required this.transcript});

  factory Audio.fromJson(Map<String, dynamic> json) => _$AudioFromJson(json);

  Map<String, dynamic> toJson() => _$AudioToJson(this);
}

@JsonSerializable()
class UrlCitation {
  int end_index;
  int start_index;
  String title;
  String url;

  UrlCitation({required this.end_index, required this.start_index, required this.title, required this.url});

  factory UrlCitation.fromJson(Map<String, dynamic> json) => _$UrlCitationFromJson(json);

  Map<String, dynamic> toJson() => _$UrlCitationToJson(this);
}

@JsonSerializable()
class FunctionCalledModel {
  String name;
  Map<String, dynamic> arguments;

  FunctionCalledModel({required this.name, required this.arguments});

  factory FunctionCalledModel.fromJson(Map<String, dynamic> json) => _$FunctionCalledModelFromJson(json);

  Map<String, dynamic> toJson() => _$FunctionCalledModelToJson(this);
}

@JsonSerializable()
class ToolCall {
  String id;
  String type;

  ToolCall({required this.id, required this.type});

  factory ToolCall.fromJson(Map<String, dynamic> json) => _$ToolCallFromJson(json);

  Map<String, dynamic> toJson() => _$ToolCallToJson(this);
}

@JsonSerializable()
class Usage {
  int completion_tokens;
  int prompt_tokens;
  int total_tokens;
  CompletionTokensDetails completion_tokens_details;
  PromptTokensDetails prompt_tokens_details;

  Usage({required this.completion_tokens, required this.prompt_tokens, required this.total_tokens, required this.completion_tokens_details, required this.prompt_tokens_details});

  factory Usage.fromJson(Map<String, dynamic> json) => _$UsageFromJson(json);

  Map<String, dynamic> toJson() => _$UsageToJson(this);
}

@JsonSerializable()
class CompletionTokensDetails {
  int accepted_prediction_tokens;
  int audio_tokens;
  int reasoning_tokens;
  int rejected_prediction_tokens;

  CompletionTokensDetails({required this.accepted_prediction_tokens, required this.audio_tokens, required this.reasoning_tokens, required this.rejected_prediction_tokens});

  factory CompletionTokensDetails.fromJson(Map<String, dynamic> json) => _$CompletionTokensDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$CompletionTokensDetailsToJson(this);
}

@JsonSerializable()
class PromptTokensDetails {
  int audio_tokens;
  int cached_tokens;

  PromptTokensDetails({required this.audio_tokens, required this.cached_tokens});

  factory PromptTokensDetails.fromJson(Map<String, dynamic> json) => _$PromptTokensDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$PromptTokensDetailsToJson(this);
}