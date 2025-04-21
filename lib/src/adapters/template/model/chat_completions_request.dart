import 'package:json_annotation/json_annotation.dart';

part 'chat_completions_request.g.dart';

/// https://docs.newllm.com/docs/api-reference/chat/create

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ChatCompletionRequest {
  List<Message> messages;
  String model;
  Audio? audio;
  int? frequency_penalty;
  @Deprecated('Deprecated in favor of tool_choice.') dynamic function_call;  /// String: `none`is the default when no functions are present; `auto` is the default if functions are present. Object: FunctionCall
  @Deprecated('Deprecated in favor of tools..') List<FunctionModel>? functions;
  Map<String, dynamic>? logit_bias;
  bool? logprobs;
  int? max_completion_tokens;
  @Deprecated('This value is now deprecated in favor of max_completion_tokens') int? max_tokens;
  Map<String, dynamic>? metadata;
  List<String>? modalities;
  int? n;
  bool? parallel_tool_calls;
  Prediction? prediction;
  int? presence_penalty;
  String? reasoning_effort; /// `low`, `medium`, `high`
  ResponseFormat? response_format;
  int? seed;
  String? service_tier; /// `auto`, `default`
  dynamic stop; /// String or List<> or null
  bool? store;
  bool? stream;
  StreamOptions? stream_options;
  double? temperature;
  dynamic tool_choice; /// String or Tool
  List<Tool>? tools;
  int? top_logprobs;
  double? top_p;
  String? user;
  WebSearchOptions? web_search_options;

  ChatCompletionRequest({
    required this.messages,
    required this.model,
    this.frequency_penalty,
    this.function_call,
    this.functions,
    this.logit_bias,
    this.logprobs,
    this.max_completion_tokens,
    this.max_tokens,
    this.metadata,
    this.modalities,
    this.n,
    this.parallel_tool_calls,
    this.prediction,
    this.presence_penalty,
    this.reasoning_effort,
    this.response_format,
    this.seed,
    this.service_tier,
    this.stop,
    this.store,
    this.stream,
    this.stream_options,
    this.temperature,
    this.tool_choice,
    this.tools,
    this.top_logprobs,
    this.top_p,
    this.user,
    this.web_search_options
  });

  factory ChatCompletionRequest.fromJson(Map<String, dynamic> json) => _$ChatCompletionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChatCompletionRequestToJson(this);
}

class RoleType {
  static final String DEVELOPER = "developer";
  static final String SYSTEM = "system";
  static final String USER = "user";
  static final String ASSISTANT = "assistant";
  static final String TOOL = "tool";
  @Deprecated('')
  static final String FUNCTION = "function";
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Message {
  String role;
  dynamic content; /// String or List<Content>
  String? name;
  @Deprecated('Deprecated and replaced by tool_calls.') FunctionCalledModel? function_call; /// for assistant
  String? refusal;  /// for assistant
  List<ToolCall>? tool_calls; /// for assistant
  String? tool_call_id; /// for tool

  Message({required this.role, required this.content, this.name, this.function_call, this.refusal, this.tool_calls, this.tool_call_id});

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Audio {
  String format;  /// `wav`, `mp3`, `flac`, `opus`, or `pcm16`
  String voice;   /// `alloy`, `ash`, `ballad`, `coral`, `echo`, `sage`, and `shimmer`

  Audio({required this.format, required this.voice});

  factory Audio.fromJson(Map<String, dynamic> json) => _$AudioFromJson(json);

  Map<String, dynamic> toJson() => _$AudioToJson(this);
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
  FunctionCalledModel function;
  String id;
  String type;

  ToolCall({required this.function, required this.id, required this.type});

  factory ToolCall.fromJson(Map<String, dynamic> json) => _$ToolCallFromJson(json);

  Map<String, dynamic> toJson() => _$ToolCallToJson(this);
}

@Deprecated('Deprecated in favor of tool_choice.')
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class FunctionCall {
  String name;
  FunctionCall({required this.name});

  factory FunctionCall.fromJson(Map<String, dynamic> json) => _$FunctionCallFromJson(json);

  Map<String, dynamic> toJson() => _$FunctionCallToJson(this);
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
class Prediction {
  String type;
  dynamic content; /// String or List<Content>

  Prediction({required this.type, this.content});

  factory Prediction.fromJson(Map<String, dynamic> json) => _$PredictionFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionToJson(this);
}


@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ResponseFormat {
  String type;  /// `text`, `json_schema`, `json_object`
  JsonSchema? json_schema; /// String or List<Content>

  ResponseFormat({required this.type, this.json_schema});

  factory ResponseFormat.fromJson(Map<String, dynamic> json) => _$ResponseFormatFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseFormatToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class JsonSchema {
  String name;
  String? description;
  Map<String, dynamic>? schema;
  bool? strict;

  JsonSchema({required this.name, this.description, this.schema, this.strict});

  factory JsonSchema.fromJson(Map<String, dynamic> json) => _$JsonSchemaFromJson(json);

  Map<String, dynamic> toJson() => _$JsonSchemaToJson(this);
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
class WebSearchOptions {
  String? search_context_size;  ///low, medium, high
  UserLocation? user_location;

  WebSearchOptions({this.search_context_size, this.user_location});

  factory WebSearchOptions.fromJson(Map<String, dynamic> json) => _$WebSearchOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$WebSearchOptionsToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class UserLocation {
  String type;  /// `approximate`
  Approximate approximate;

  UserLocation({required this.type, required this.approximate});

  factory UserLocation.fromJson(Map<String, dynamic> json) => _$UserLocationFromJson(json);

  Map<String, dynamic> toJson() => _$UserLocationToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Approximate {
  String? city;
  String? country;
  String? region;
  String? timezone;

  Approximate({this.city, this.country, this.region, this.timezone});

  factory Approximate.fromJson(Map<String, dynamic> json) => _$ApproximateFromJson(json);

  Map<String, dynamic> toJson() => _$ApproximateToJson(this);
}
