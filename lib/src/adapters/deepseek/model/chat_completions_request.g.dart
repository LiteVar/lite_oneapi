// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_completions_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatCompletionRequest _$ChatCompletionRequestFromJson(
  Map<String, dynamic> json,
) => ChatCompletionRequest(
  messages:
      (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
  model: json['model'] as String,
  frequency_penalty: (json['frequency_penalty'] as num?)?.toInt(),
  max_tokens: (json['max_tokens'] as num?)?.toInt(),
  presence_penalty: (json['presence_penalty'] as num?)?.toInt(),
  response_format:
      json['response_format'] == null
          ? null
          : ResponseFormat.fromJson(
            json['response_format'] as Map<String, dynamic>,
          ),
  stop: json['stop'],
  stream: json['stream'] as bool?,
  stream_options:
      json['stream_options'] == null
          ? null
          : StreamOptions.fromJson(
            json['stream_options'] as Map<String, dynamic>,
          ),
  temperature: (json['temperature'] as num?)?.toDouble(),
  tool_choice: json['tool_choice'],
  top_p: (json['top_p'] as num?)?.toDouble(),
  tools:
      (json['tools'] as List<dynamic>?)
          ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
          .toList(),
  logprobs: json['logprobs'] as bool?,
  top_logprobs: (json['top_logprobs'] as num?)?.toInt(),
);

Map<String, dynamic> _$ChatCompletionRequestToJson(
  ChatCompletionRequest instance,
) => <String, dynamic>{
  'messages': instance.messages,
  'model': instance.model,
  if (instance.frequency_penalty case final value?) 'frequency_penalty': value,
  if (instance.max_tokens case final value?) 'max_tokens': value,
  if (instance.presence_penalty case final value?) 'presence_penalty': value,
  if (instance.response_format case final value?) 'response_format': value,
  if (instance.stop case final value?) 'stop': value,
  if (instance.stream case final value?) 'stream': value,
  if (instance.stream_options case final value?) 'stream_options': value,
  if (instance.temperature case final value?) 'temperature': value,
  if (instance.top_p case final value?) 'top_p': value,
  if (instance.tools case final value?) 'tools': value,
  if (instance.tool_choice case final value?) 'tool_choice': value,
  if (instance.logprobs case final value?) 'logprobs': value,
  if (instance.top_logprobs case final value?) 'top_logprobs': value,
};

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  role: json['role'] as String,
  content: json['content'] as String,
  name: json['name'] as String?,
  prefix: json['prefix'] as bool?,
  reasoning_content: json['reasoning_content'] as String?,
  tool_calls:
      (json['tool_calls'] as List<dynamic>?)
          ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
  tool_call_id: json['tool_call_id'] as String?,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'role': instance.role,
  'content': instance.content,
  if (instance.name case final value?) 'name': value,
  if (instance.prefix case final value?) 'prefix': value,
  if (instance.reasoning_content case final value?) 'reasoning_content': value,
  if (instance.tool_calls case final value?) 'tool_calls': value,
  if (instance.tool_call_id case final value?) 'tool_call_id': value,
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
  'function': instance.function,
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
      if (instance.description case final value?) 'description': value,
      if (instance.parameters case final value?) 'parameters': value,
      if (instance.strict case final value?) 'strict': value,
    };

ResponseFormat _$ResponseFormatFromJson(Map<String, dynamic> json) =>
    ResponseFormat(type: json['type'] as String);

Map<String, dynamic> _$ResponseFormatToJson(ResponseFormat instance) =>
    <String, dynamic>{'type': instance.type};

StreamOptions _$StreamOptionsFromJson(Map<String, dynamic> json) =>
    StreamOptions(include_usage: json['include_usage'] as bool?);

Map<String, dynamic> _$StreamOptionsToJson(StreamOptions instance) =>
    <String, dynamic>{
      if (instance.include_usage case final value?) 'include_usage': value,
    };

Tool _$ToolFromJson(Map<String, dynamic> json) => Tool(
  type: json['type'] as String,
  function: FunctionModel.fromJson(json['function'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ToolToJson(Tool instance) => <String, dynamic>{
  'type': instance.type,
  'function': instance.function,
};
