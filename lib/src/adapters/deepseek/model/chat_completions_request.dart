import 'package:json_annotation/json_annotation.dart';

part 'chat_completions_request.g.dart';

/// https://api-docs.deepseek.com/zh-cn/api/create-chat-completion#request

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ChatCompletionRequest {
  List<Message> messages;
  String model;
  int? frequency_penalty;
  int? max_tokens;
  int? presence_penalty;
  ResponseFormat? response_format;
  dynamic stop; /// String or List<String> or null
  bool? stream;
  StreamOptions? stream_options;
  double? temperature;
  double? top_p;
  List<Tool>? tools;
  dynamic tool_choice; /// String: `none`, `auto`, `required` or Tool
  bool? logprobs;
  int? top_logprobs;

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

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Message {
  String role;
  String content;
  String? name;
  bool? prefix;  /// for assistant
  String? reasoning_content; /// for assistant
  List<ToolCall>? tool_calls; /// for assistant, NOT show in official docs!!!
  String? tool_call_id; /// for tool

  Message({required this.role, required this.content, this.name, this.prefix, this.reasoning_content, this.tool_calls, this.tool_call_id});

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
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
  FunctionCalledModel function;
  String id;
  String type;

  ToolCall({required this.function, required this.id, required this.type});

  factory ToolCall.fromJson(Map<String, dynamic> json) => _$ToolCallFromJson(json);

  Map<String, dynamic> toJson() => _$ToolCallToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class FunctionModel {
  String name;
  String? description;
  Map<String, dynamic>? parameters;
  bool? strict;

  FunctionModel({required this.name, this.description, this.parameters, this.strict});

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
  String type;  /// `function`
  FunctionModel function;

  Tool({required this.type, required this.function});

  factory Tool.fromJson(Map<String, dynamic> json) => _$ToolFromJson(json);

  Map<String, dynamic> toJson() => _$ToolToJson(this);
}