// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_completions_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatCompletionRequest _$ChatCompletionRequestFromJson(
  Map<String, dynamic> json,
) => ChatCompletionRequest(
  messages: (json['messages'] as List<dynamic>)
      .map((e) => Message.fromJson(e as Map<String, dynamic>))
      .toList(),
  model: json['model'] as String,
  frequency_penalty: (json['frequency_penalty'] as num?)?.toDouble(),
  max_tokens: (json['max_tokens'] as num?)?.toInt(),
  presence_penalty: (json['presence_penalty'] as num?)?.toDouble(),
  thinking: json['thinking'] == null
      ? null
      : Thinking.fromJson(json['thinking'] as Map<String, dynamic>),
  reasoning_effort: json['reasoning_effort'] as String?,
  response_format: json['response_format'] == null
      ? null
      : ResponseFormat.fromJson(
          json['response_format'] as Map<String, dynamic>,
        ),
  stop: json['stop'],
  stream: json['stream'] as bool?,
  stream_options: json['stream_options'] == null
      ? null
      : StreamOptions.fromJson(json['stream_options'] as Map<String, dynamic>),
  temperature: (json['temperature'] as num?)?.toDouble(),
  tool_choice: json['tool_choice'],
  top_p: (json['top_p'] as num?)?.toDouble(),
  tools: (json['tools'] as List<dynamic>?)
      ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
      .toList(),
  logprobs: json['logprobs'] as bool?,
  top_logprobs: (json['top_logprobs'] as num?)?.toInt(),
);

Map<String, dynamic> _$ChatCompletionRequestToJson(
  ChatCompletionRequest instance,
) => <String, dynamic>{
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'model': instance.model,
  'frequency_penalty': ?instance.frequency_penalty,
  'max_tokens': ?instance.max_tokens,
  'presence_penalty': ?instance.presence_penalty,
  'thinking': ?instance.thinking?.toJson(),
  'reasoning_effort': ?instance.reasoning_effort,
  'response_format': ?instance.response_format?.toJson(),
  'stop': ?instance.stop,
  'stream': ?instance.stream,
  'stream_options': ?instance.stream_options?.toJson(),
  'temperature': ?instance.temperature,
  'top_p': ?instance.top_p,
  'tools': ?instance.tools?.map((e) => e.toJson()).toList(),
  'tool_choice': ?instance.tool_choice,
  'logprobs': ?instance.logprobs,
  'top_logprobs': ?instance.top_logprobs,
};

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  role: json['role'] as String,
  content: json['content'] as String,
  name: json['name'] as String?,
  prefix: json['prefix'] as bool?,
  reasoning_content: json['reasoning_content'] as String?,
  tool_calls: (json['tool_calls'] as List<dynamic>?)
      ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
      .toList(),
  tool_call_id: json['tool_call_id'] as String?,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'role': instance.role,
  'content': instance.content,
  'name': ?instance.name,
  'prefix': ?instance.prefix,
  'reasoning_content': ?instance.reasoning_content,
  'tool_calls': ?instance.tool_calls?.map((e) => e.toJson()).toList(),
  'tool_call_id': ?instance.tool_call_id,
};

FunctionCalledModel _$FunctionCalledModelFromJson(Map<String, dynamic> json) =>
    FunctionCalledModel(
      name: json['name'] as String,
      arguments: json['arguments'] as String,
    );

Map<String, dynamic> _$FunctionCalledModelToJson(
  FunctionCalledModel instance,
) => <String, dynamic>{'name': instance.name, 'arguments': instance.arguments};

ToolCall _$ToolCallFromJson(Map<String, dynamic> json) => ToolCall(
  function: FunctionCalledModel.fromJson(
    json['function'] as Map<String, dynamic>,
  ),
  id: json['id'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$ToolCallToJson(ToolCall instance) => <String, dynamic>{
  'function': instance.function.toJson(),
  'id': instance.id,
  'type': instance.type,
};

FunctionModel _$FunctionModelFromJson(Map<String, dynamic> json) =>
    FunctionModel(
      name: json['name'] as String,
      description: json['description'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
      strict: json['strict'] as bool?,
    );

Map<String, dynamic> _$FunctionModelToJson(FunctionModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': ?instance.description,
      'parameters': ?instance.parameters,
      'strict': ?instance.strict,
    };

Thinking _$ThinkingFromJson(Map<String, dynamic> json) =>
    Thinking(type: json['type'] as String);

Map<String, dynamic> _$ThinkingToJson(Thinking instance) => <String, dynamic>{
  'type': instance.type,
};

ResponseFormat _$ResponseFormatFromJson(Map<String, dynamic> json) =>
    ResponseFormat(type: json['type'] as String);

Map<String, dynamic> _$ResponseFormatToJson(ResponseFormat instance) =>
    <String, dynamic>{'type': instance.type};

StreamOptions _$StreamOptionsFromJson(Map<String, dynamic> json) =>
    StreamOptions(include_usage: json['include_usage'] as bool?);

Map<String, dynamic> _$StreamOptionsToJson(StreamOptions instance) =>
    <String, dynamic>{'include_usage': ?instance.include_usage};

Tool _$ToolFromJson(Map<String, dynamic> json) => Tool(
  type: json['type'] as String,
  function: FunctionModel.fromJson(json['function'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ToolToJson(Tool instance) => <String, dynamic>{
  'type': instance.type,
  'function': instance.function.toJson(),
};
