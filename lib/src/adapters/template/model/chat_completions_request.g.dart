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
    function_call: json['function_call'],
    functions:
        (json['functions'] as List<dynamic>?)
            ?.map((e) => FunctionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
    logit_bias: json['logit_bias'] as Map<String, dynamic>?,
    logprobs: json['logprobs'] as bool?,
    max_completion_tokens: (json['max_completion_tokens'] as num?)?.toInt(),
    max_tokens: (json['max_tokens'] as num?)?.toInt(),
    metadata: json['metadata'] as Map<String, dynamic>?,
    modalities:
        (json['modalities'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
    n: (json['n'] as num?)?.toInt(),
    parallel_tool_calls: json['parallel_tool_calls'] as bool?,
    prediction:
        json['prediction'] == null
            ? null
            : Prediction.fromJson(json['prediction'] as Map<String, dynamic>),
    presence_penalty: (json['presence_penalty'] as num?)?.toInt(),
    reasoning_effort: json['reasoning_effort'] as String?,
    response_format:
        json['response_format'] == null
            ? null
            : ResponseFormat.fromJson(
              json['response_format'] as Map<String, dynamic>,
            ),
    seed: (json['seed'] as num?)?.toInt(),
    service_tier: json['service_tier'] as String?,
    stop: json['stop'],
    store: json['store'] as bool?,
    stream: json['stream'] as bool?,
    stream_options:
        json['stream_options'] == null
            ? null
            : StreamOptions.fromJson(
              json['stream_options'] as Map<String, dynamic>,
            ),
    temperature: (json['temperature'] as num?)?.toDouble(),
    tool_choice: json['tool_choice'],
    tools:
        (json['tools'] as List<dynamic>?)
            ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
            .toList(),
    top_logprobs: (json['top_logprobs'] as num?)?.toInt(),
    top_p: (json['top_p'] as num?)?.toDouble(),
    user: json['user'] as String?,
    web_search_options:
        json['web_search_options'] == null
            ? null
            : WebSearchOptions.fromJson(
              json['web_search_options'] as Map<String, dynamic>,
            ),
  )
  ..audio =
      json['audio'] == null
          ? null
          : Audio.fromJson(json['audio'] as Map<String, dynamic>);

Map<String, dynamic> _$ChatCompletionRequestToJson(
  ChatCompletionRequest instance,
) => <String, dynamic>{
  'messages': instance.messages,
  'model': instance.model,
  if (instance.audio case final value?) 'audio': value,
  if (instance.frequency_penalty case final value?) 'frequency_penalty': value,
  if (instance.function_call case final value?) 'function_call': value,
  if (instance.functions case final value?) 'functions': value,
  if (instance.logit_bias case final value?) 'logit_bias': value,
  if (instance.logprobs case final value?) 'logprobs': value,
  if (instance.max_completion_tokens case final value?)
    'max_completion_tokens': value,
  if (instance.max_tokens case final value?) 'max_tokens': value,
  if (instance.metadata case final value?) 'metadata': value,
  if (instance.modalities case final value?) 'modalities': value,
  if (instance.n case final value?) 'n': value,
  if (instance.parallel_tool_calls case final value?)
    'parallel_tool_calls': value,
  if (instance.prediction case final value?) 'prediction': value,
  if (instance.presence_penalty case final value?) 'presence_penalty': value,
  if (instance.reasoning_effort case final value?) 'reasoning_effort': value,
  if (instance.response_format case final value?) 'response_format': value,
  if (instance.seed case final value?) 'seed': value,
  if (instance.service_tier case final value?) 'service_tier': value,
  if (instance.stop case final value?) 'stop': value,
  if (instance.store case final value?) 'store': value,
  if (instance.stream case final value?) 'stream': value,
  if (instance.stream_options case final value?) 'stream_options': value,
  if (instance.temperature case final value?) 'temperature': value,
  if (instance.tool_choice case final value?) 'tool_choice': value,
  if (instance.tools case final value?) 'tools': value,
  if (instance.top_logprobs case final value?) 'top_logprobs': value,
  if (instance.top_p case final value?) 'top_p': value,
  if (instance.user case final value?) 'user': value,
  if (instance.web_search_options case final value?)
    'web_search_options': value,
};

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  role: json['role'] as String,
  content: json['content'],
  name: json['name'] as String?,
  function_call:
      json['function_call'] == null
          ? null
          : FunctionCalledModel.fromJson(
            json['function_call'] as Map<String, dynamic>,
          ),
  refusal: json['refusal'] as String?,
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
  if (instance.function_call case final value?) 'function_call': value,
  if (instance.refusal case final value?) 'refusal': value,
  if (instance.tool_calls case final value?) 'tool_calls': value,
  if (instance.tool_call_id case final value?) 'tool_call_id': value,
};

Audio _$AudioFromJson(Map<String, dynamic> json) =>
    Audio(format: json['format'] as String, voice: json['voice'] as String);

Map<String, dynamic> _$AudioToJson(Audio instance) => <String, dynamic>{
  'format': instance.format,
  'voice': instance.voice,
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

FunctionCall _$FunctionCallFromJson(Map<String, dynamic> json) =>
    FunctionCall(name: json['name'] as String);

Map<String, dynamic> _$FunctionCallToJson(FunctionCall instance) =>
    <String, dynamic>{'name': instance.name};

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

Prediction _$PredictionFromJson(Map<String, dynamic> json) =>
    Prediction(type: json['type'] as String, content: json['content']);

Map<String, dynamic> _$PredictionToJson(Prediction instance) =>
    <String, dynamic>{'type': instance.type, 'content': instance.content};

ResponseFormat _$ResponseFormatFromJson(Map<String, dynamic> json) =>
    ResponseFormat(
      type: json['type'] as String,
      json_schema:
          json['json_schema'] == null
              ? null
              : JsonSchema.fromJson(
                json['json_schema'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$ResponseFormatToJson(ResponseFormat instance) =>
    <String, dynamic>{
      'type': instance.type,
      if (instance.json_schema case final value?) 'json_schema': value,
    };

JsonSchema _$JsonSchemaFromJson(Map<String, dynamic> json) => JsonSchema(
  name: json['name'] as String,
  description: json['description'] as String?,
  schema: json['schema'] as Map<String, dynamic>?,
  strict: json['strict'] as bool?,
);

Map<String, dynamic> _$JsonSchemaToJson(JsonSchema instance) =>
    <String, dynamic>{
      'name': instance.name,
      if (instance.description case final value?) 'description': value,
      'schema': instance.schema,
      if (instance.strict case final value?) 'strict': value,
    };

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

WebSearchOptions _$WebSearchOptionsFromJson(Map<String, dynamic> json) =>
    WebSearchOptions(
      search_context_size: json['search_context_size'] as String?,
      user_location:
          json['user_location'] == null
              ? null
              : UserLocation.fromJson(
                json['user_location'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$WebSearchOptionsToJson(WebSearchOptions instance) =>
    <String, dynamic>{
      if (instance.search_context_size case final value?)
        'search_context_size': value,
      if (instance.user_location case final value?) 'user_location': value,
    };

UserLocation _$UserLocationFromJson(Map<String, dynamic> json) => UserLocation(
  type: json['type'] as String,
  approximate: Approximate.fromJson(
    json['approximate'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$UserLocationToJson(UserLocation instance) =>
    <String, dynamic>{
      'type': instance.type,
      'approximate': instance.approximate,
    };

Approximate _$ApproximateFromJson(Map<String, dynamic> json) => Approximate(
  city: json['city'] as String?,
  country: json['country'] as String?,
  region: json['region'] as String?,
  timezone: json['timezone'] as String?,
);

Map<String, dynamic> _$ApproximateToJson(Approximate instance) =>
    <String, dynamic>{
      if (instance.city case final value?) 'city': value,
      if (instance.country case final value?) 'country': value,
      if (instance.region case final value?) 'region': value,
      if (instance.timezone case final value?) 'timezone': value,
    };
