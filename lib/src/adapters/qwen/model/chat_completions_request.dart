import 'package:json_annotation/json_annotation.dart';

part 'chat_completions_request.g.dart';

/// https://help.aliyun.com/zh/model-studio/developer-reference/use-qwen-by-calling-api#f4514ce9072sb

@JsonSerializable()
class ChatCompletionRequest {
  String model;
  List<Message> messages;
  @JsonKey(includeIfNull: false) bool? stream;
  @JsonKey(includeIfNull: false) StreamOptions? stream_options;
  @JsonKey(includeIfNull: false) List<String>? modalities;
  @JsonKey(includeIfNull: false) double? temperature;
  @JsonKey(includeIfNull: false) double? top_p;
  @JsonKey(includeIfNull: false) int? presence_penalty;
  @JsonKey(includeIfNull: false) ResponseFormat? response_format;
  @JsonKey(includeIfNull: false) int? max_tokens;
  @JsonKey(includeIfNull: false) int? n;
  @JsonKey(includeIfNull: false) int? seed;
  @JsonKey(includeIfNull: false) dynamic stop; /// String or List<> or null
  @JsonKey(includeIfNull: false) List<Tool>? tools;
  @JsonKey(includeIfNull: false) dynamic tool_choice; /// String or Tool
  @JsonKey(includeIfNull: false) bool? parallel_tool_calls;
  @JsonKey(includeIfNull: false) TranslationOptions? translation_options;
  @JsonKey(includeIfNull: false) bool? enable_search;
  @JsonKey(includeIfNull: false, name: "X-DashScope-DataInspection") String? x_dashScope_dataInspection;

  ChatCompletionRequest({
    required this.model,
    required this.messages,
    this.stream,
    this.stream_options,
    this.modalities,
    this.temperature,
    this.top_p,
    this.presence_penalty,
    this.response_format,
    this.max_tokens,
    this.n,
    this.seed,
    this.stop,
    this.tools,
    this.tool_choice,
    this.parallel_tool_calls,
    this.translation_options,
    this.enable_search,
    this.x_dashScope_dataInspection,
  });

  factory ChatCompletionRequest.fromJson(Map<String, dynamic> json) => _$ChatCompletionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChatCompletionRequestToJson(this);
}

class RoleType {
  static final String SYSTEM = "system";
  static final String USER = "user";
  static final String ASSISTANT = "assistant";
  static final String TOOL = "tool";
}

@JsonSerializable()
class Message {
  String role;
  dynamic content; /// String or List<Content>
  @JsonKey(includeIfNull: false) bool? partial;  /// for assistant
  @JsonKey(includeIfNull: false) List<ToolCall>? tool_calls; /// for assistant
  @JsonKey(includeIfNull: false) String? tool_call_id; /// for tool

  Message({required this.role, required this.content, this.partial, this.tool_calls, this.tool_call_id});

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class Content {
  String type;
  @JsonKey(includeIfNull: false) String? text;
  @JsonKey(includeIfNull: false) String? image_url;
  @JsonKey(includeIfNull: false) String? refusal;
  Content({required this.type, this.text, this.refusal, this.image_url});

  factory Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);

  Map<String, dynamic> toJson() => _$ContentToJson(this);
}

@JsonSerializable()
class FunctionCalledModel {
  String name;
  String arguments;

  FunctionCalledModel({required this.name, required this.arguments});

  factory FunctionCalledModel.fromJson(Map<String, dynamic> json) => _$FunctionCalledModelFromJson(json);

  Map<String, dynamic> toJson() => _$FunctionCalledModelToJson(this);
}

@JsonSerializable()
class ToolCall {
  String id;
  String type;
  FunctionCalledModel function;

  ToolCall({required this.id, required this.type, required this.function});

  factory ToolCall.fromJson(Map<String, dynamic> json) => _$ToolCallFromJson(json);

  Map<String, dynamic> toJson() => _$ToolCallToJson(this);
}

@JsonSerializable()
class FunctionModel {
  String name;
  @JsonKey(includeIfNull: false) String? description;
  @JsonKey(includeIfNull: false) Map<String, dynamic>? parameters;

  FunctionModel({required this.name, this.description, this.parameters});

  factory FunctionModel.fromJson(Map<String, dynamic> json) => _$FunctionModelFromJson(json);

  Map<String, dynamic> toJson() => _$FunctionModelToJson(this);
}

@JsonSerializable()
class ResponseFormat {
  String type;  /// `text`, `json_object`

  ResponseFormat({required this.type});

  factory ResponseFormat.fromJson(Map<String, dynamic> json) => _$ResponseFormatFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseFormatToJson(this);
}

@JsonSerializable()
class StreamOptions {
  @JsonKey(includeIfNull: false) bool? include_usage;

  StreamOptions({required this.include_usage});

  factory StreamOptions.fromJson(Map<String, dynamic> json) => _$StreamOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$StreamOptionsToJson(this);
}

@JsonSerializable()
class Tool {
  String type;
  FunctionModel function;

  Tool({required this.type, required this.function});

  factory Tool.fromJson(Map<String, dynamic> json) => _$ToolFromJson(json);

  Map<String, dynamic> toJson() => _$ToolToJson(this);
}

@JsonSerializable()
class TranslationOptions {
  String source_lang;
  String target_lang;
  @JsonKey(includeIfNull: false) List<Term>? terms;
  @JsonKey(includeIfNull: false) List<Term>? tm_list;
  @JsonKey(includeIfNull: false) String? domains;

  TranslationOptions({required this.source_lang, required this.target_lang, this.terms, this.tm_list, this.domains});

  factory TranslationOptions.fromJson(Map<String, dynamic> json) => _$TranslationOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationOptionsToJson(this);
}

@JsonSerializable()
class Term {
  String source;
  String target;

  Term({required this.source, required this.target});

  factory Term.fromJson(Map<String, dynamic> json) => _$TermFromJson(json);

  Map<String, dynamic> toJson() => _$TermToJson(this);
}