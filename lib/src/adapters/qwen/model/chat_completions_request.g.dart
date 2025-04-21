// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_completions_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatCompletionRequest _$ChatCompletionRequestFromJson(
  Map<String, dynamic> json,
) => ChatCompletionRequest(
  model: json['model'] as String,
  messages:
      (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
  stream: json['stream'] as bool?,
  stream_options:
      json['stream_options'] == null
          ? null
          : StreamOptions.fromJson(
            json['stream_options'] as Map<String, dynamic>,
          ),
  modalities:
      (json['modalities'] as List<dynamic>?)?.map((e) => e as String).toList(),
  temperature: (json['temperature'] as num?)?.toDouble(),
  top_p: (json['top_p'] as num?)?.toDouble(),
  presence_penalty: (json['presence_penalty'] as num?)?.toInt(),
  response_format:
      json['response_format'] == null
          ? null
          : ResponseFormat.fromJson(
            json['response_format'] as Map<String, dynamic>,
          ),
  max_tokens: (json['max_tokens'] as num?)?.toInt(),
  n: (json['n'] as num?)?.toInt(),
  seed: (json['seed'] as num?)?.toInt(),
  stop: json['stop'],
  tools:
      (json['tools'] as List<dynamic>?)
          ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
          .toList(),
  tool_choice: json['tool_choice'],
  parallel_tool_calls: json['parallel_tool_calls'] as bool?,
  translation_options:
      json['translation_options'] == null
          ? null
          : TranslationOptions.fromJson(
            json['translation_options'] as Map<String, dynamic>,
          ),
  enable_search: json['enable_search'] as bool?,
  x_dashScope_dataInspection: json['X-DashScope-DataInspection'] as String?,
);

Map<String, dynamic> _$ChatCompletionRequestToJson(
  ChatCompletionRequest instance,
) => <String, dynamic>{
  'model': instance.model,
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  if (instance.stream case final value?) 'stream': value,
  if (instance.stream_options?.toJson() case final value?)
    'stream_options': value,
  if (instance.modalities case final value?) 'modalities': value,
  if (instance.temperature case final value?) 'temperature': value,
  if (instance.top_p case final value?) 'top_p': value,
  if (instance.presence_penalty case final value?) 'presence_penalty': value,
  if (instance.response_format?.toJson() case final value?)
    'response_format': value,
  if (instance.max_tokens case final value?) 'max_tokens': value,
  if (instance.n case final value?) 'n': value,
  if (instance.seed case final value?) 'seed': value,
  if (instance.stop case final value?) 'stop': value,
  if (instance.tools?.map((e) => e.toJson()).toList() case final value?)
    'tools': value,
  if (instance.tool_choice case final value?) 'tool_choice': value,
  if (instance.parallel_tool_calls case final value?)
    'parallel_tool_calls': value,
  if (instance.translation_options?.toJson() case final value?)
    'translation_options': value,
  if (instance.enable_search case final value?) 'enable_search': value,
  if (instance.x_dashScope_dataInspection case final value?)
    'X-DashScope-DataInspection': value,
};

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  role: json['role'] as String,
  content: json['content'],
  partial: json['partial'] as bool?,
  tool_calls:
      (json['tool_calls'] as List<dynamic>?)
          ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
  tool_call_id: json['tool_call_id'] as String?,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'role': instance.role,
  if (instance.content case final value?) 'content': value,
  if (instance.partial case final value?) 'partial': value,
  if (instance.tool_calls?.map((e) => e.toJson()).toList() case final value?)
    'tool_calls': value,
  if (instance.tool_call_id case final value?) 'tool_call_id': value,
};

Content _$ContentFromJson(Map<String, dynamic> json) => Content(
  type: json['type'] as String,
  text: json['text'] as String?,
  refusal: json['refusal'] as String?,
  image_url: json['image_url'] as String?,
);

Map<String, dynamic> _$ContentToJson(Content instance) => <String, dynamic>{
  'type': instance.type,
  if (instance.text case final value?) 'text': value,
  if (instance.image_url case final value?) 'image_url': value,
  if (instance.refusal case final value?) 'refusal': value,
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
  id: json['id'] as String,
  type: json['type'] as String,
  function: FunctionCalledModel.fromJson(
    json['function'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ToolCallToJson(ToolCall instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'function': instance.function.toJson(),
};

FunctionModel _$FunctionModelFromJson(Map<String, dynamic> json) =>
    FunctionModel(
      name: json['name'] as String,
      description: json['description'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$FunctionModelToJson(FunctionModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      if (instance.description case final value?) 'description': value,
      if (instance.parameters case final value?) 'parameters': value,
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
  'function': instance.function.toJson(),
};

TranslationOptions _$TranslationOptionsFromJson(Map<String, dynamic> json) =>
    TranslationOptions(
      source_lang: json['source_lang'] as String,
      target_lang: json['target_lang'] as String,
      terms:
          (json['terms'] as List<dynamic>?)
              ?.map((e) => Term.fromJson(e as Map<String, dynamic>))
              .toList(),
      tm_list:
          (json['tm_list'] as List<dynamic>?)
              ?.map((e) => Term.fromJson(e as Map<String, dynamic>))
              .toList(),
      domains: json['domains'] as String?,
    );

Map<String, dynamic> _$TranslationOptionsToJson(TranslationOptions instance) =>
    <String, dynamic>{
      'source_lang': instance.source_lang,
      'target_lang': instance.target_lang,
      if (instance.terms?.map((e) => e.toJson()).toList() case final value?)
        'terms': value,
      if (instance.tm_list?.map((e) => e.toJson()).toList() case final value?)
        'tm_list': value,
      if (instance.domains case final value?) 'domains': value,
    };

Term _$TermFromJson(Map<String, dynamic> json) =>
    Term(source: json['source'] as String, target: json['target'] as String);

Map<String, dynamic> _$TermToJson(Term instance) => <String, dynamic>{
  'source': instance.source,
  'target': instance.target,
};
