import 'package:json_annotation/json_annotation.dart';

part 'chat_completions_request.g.dart';

/// https://help.aliyun.com/zh/model-studio/developer-reference/use-qwen-by-calling-api#f4514ce9072sb

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ChatCompletionRequest {
  String model;
  List<Message> messages;
  bool? stream;
  StreamOptions? stream_options;
  List<String>? modalities;
  double? temperature;
  double? top_p;
  int? presence_penalty;
  ResponseFormat? response_format;
  int? max_tokens;
  int? n;
  int? seed;
  dynamic stop; /// String or List<> or null
  List<Tool>? tools;
  dynamic tool_choice; /// String or Tool
  bool? parallel_tool_calls;
  TranslationOptions? translation_options;
  bool? enable_search;
  @JsonKey(name: "X-DashScope-DataInspection") String? x_dashScope_dataInspection;

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

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Message {
  String role;
  dynamic content; /// String or List<Content>
  bool? partial;  /// for assistant
  List<ToolCall>? tool_calls; /// for assistant
  String? tool_call_id; /// for tool

  Message({required this.role, required this.content, this.partial, this.tool_calls, this.tool_call_id});

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Content {
  String type;
  String? text;
  String? image_url;
  String? refusal;
  Content({required this.type, this.text, this.refusal, this.image_url});

  factory Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);

  Map<String, dynamic> toJson() => _$ContentToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class FunctionCalledModel {
  String name;
  String arguments;

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
class FunctionModel {
  String name;
  String? description;
  Map<String, dynamic>? parameters;

  FunctionModel({required this.name, this.description, this.parameters});

  factory FunctionModel.fromJson(Map<String, dynamic> json) => _$FunctionModelFromJson(json);

  Map<String, dynamic> toJson() => _$FunctionModelToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ResponseFormat {
  String type;  /// `text`, `json_object`

  ResponseFormat({required this.type});

  factory ResponseFormat.fromJson(Map<String, dynamic> json) => _$ResponseFormatFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseFormatToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class StreamOptions {
  bool? include_usage;

  StreamOptions({required this.include_usage});

  factory StreamOptions.fromJson(Map<String, dynamic> json) => _$StreamOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$StreamOptionsToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Tool {
  String type;
  FunctionModel function;

  Tool({required this.type, required this.function});

  factory Tool.fromJson(Map<String, dynamic> json) => _$ToolFromJson(json);

  Map<String, dynamic> toJson() => _$ToolToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TranslationOptions {
  String source_lang;
  String target_lang;
  List<Term>? terms;
  List<Term>? tm_list;
  String? domains;

  TranslationOptions({required this.source_lang, required this.target_lang, this.terms, this.tm_list, this.domains});

  factory TranslationOptions.fromJson(Map<String, dynamic> json) => _$TranslationOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationOptionsToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Term {
  String source;
  String target;

  Term({required this.source, required this.target});

  factory Term.fromJson(Map<String, dynamic> json) => _$TermFromJson(json);

  Map<String, dynamic> toJson() => _$TermToJson(this);
}