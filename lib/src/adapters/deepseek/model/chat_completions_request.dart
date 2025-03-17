import 'package:json_annotation/json_annotation.dart';

part 'chat_completions_request.g.dart';

/// https://api-docs.deepseek.com/zh-cn/api/create-chat-completion#request

@JsonSerializable()
class ChatCompletionRequest {
  List<Message> messages;
  String model;
  @JsonKey(includeIfNull: false) int? frequency_penalty;
  @JsonKey(includeIfNull: false) int? max_tokens;
  @JsonKey(includeIfNull: false) int? presence_penalty;
  @JsonKey(includeIfNull: false) ResponseFormat? response_format;
  @JsonKey(includeIfNull: false) dynamic stop; /// String or List<String> or null
  @JsonKey(includeIfNull: false) bool? stream;
  @JsonKey(includeIfNull: false) StreamOptions? stream_options;
  @JsonKey(includeIfNull: false) double? temperature;
  @JsonKey(includeIfNull: false) double? top_p;
  @JsonKey(includeIfNull: false) List<Tool>? tools;
  @JsonKey(includeIfNull: false) dynamic tool_choice; /// String: `none`, `auto`, `required` or Tool
  @JsonKey(includeIfNull: false) bool? logprobs;
  @JsonKey(includeIfNull: false) int? top_logprobs;

  ChatCompletionRequest({
    required this.messages,
    required this.model,
    this.frequency_penalty,
    this.max_tokens,
    this.presence_penalty,
    this.response_format,
    this.stop,
    this.stream,
    this.stream_options,
    this.temperature,
    this.tool_choice,
    this.top_p,
    this.tools,
    this.logprobs,
    this.top_logprobs,
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
  String content;
  @JsonKey(includeIfNull: false) String? name;
  @JsonKey(includeIfNull: false) bool? prefix;  /// for assistant
  @JsonKey(includeIfNull: false) String? reasoning_content; /// for assistant
  @JsonKey(includeIfNull: false) List<ToolCall>? tool_calls; /// for assistant, NOT show in official docs!!!
  @JsonKey(includeIfNull: false) String? tool_call_id; /// for tool

  Message({required this.role, required this.content, this.name, this.prefix, this.reasoning_content, this.tool_calls, this.tool_call_id});

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
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
  FunctionCalledModel function;
  String id;
  String type;

  ToolCall({required this.function, required this.id, required this.type});

  factory ToolCall.fromJson(Map<String, dynamic> json) => _$ToolCallFromJson(json);

  Map<String, dynamic> toJson() => _$ToolCallToJson(this);
}

@JsonSerializable()
class FunctionModel {
  String name;
  @JsonKey(includeIfNull: false) String? description;
  @JsonKey(includeIfNull: false) Map<String, dynamic>? parameters;
  @JsonKey(includeIfNull: false) bool? strict;

  FunctionModel({required this.name, this.description, this.parameters, this.strict});

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
  String type;  /// `function`
  FunctionModel function;

  Tool({required this.type, required this.function});

  factory Tool.fromJson(Map<String, dynamic> json) => _$ToolFromJson(json);

  Map<String, dynamic> toJson() => _$ToolToJson(this);
}