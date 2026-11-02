// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_completions_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatCompletionRequest _$ChatCompletionRequestFromJson(
  Map<String, dynamic> json,
) =>
    ChatCompletionRequest(
        messages: (json['messages'] as List<dynamic>)
            .map((e) => Message.fromJson(e as Map<String, dynamic>))
            .toList(),
        model: json['model'] as String,
        frequency_penalty: (json['frequency_penalty'] as num?)?.toDouble(),
        function_call: json['function_call'],
        functions: (json['functions'] as List<dynamic>?)
            ?.map((e) => FunctionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        logit_bias: json['logit_bias'] as Map<String, dynamic>?,
        logprobs: json['logprobs'] as bool?,
        max_completion_tokens: (json['max_completion_tokens'] as num?)?.toInt(),
        max_tokens: (json['max_tokens'] as num?)?.toInt(),
        metadata: json['metadata'] as Map<String, dynamic>?,
        modalities: (json['modalities'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        n: (json['n'] as num?)?.toInt(),
        parallel_tool_calls: json['parallel_tool_calls'] as bool?,
        prediction: json['prediction'] == null
            ? null
            : Prediction.fromJson(json['prediction'] as Map<String, dynamic>),
        presence_penalty: (json['presence_penalty'] as num?)?.toDouble(),
        reasoning_effort: json['reasoning_effort'] as String?,
        response_format: json['response_format'] == null
            ? null
            : ResponseFormat.fromJson(
                json['response_format'] as Map<String, dynamic>,
              ),
        seed: (json['seed'] as num?)?.toInt(),
        service_tier: json['service_tier'] as String?,
        stop: json['stop'],
        store: json['store'] as bool?,
        stream: json['stream'] as bool?,
        stream_options: json['stream_options'] == null
            ? null
            : StreamOptions.fromJson(
                json['stream_options'] as Map<String, dynamic>,
              ),
        temperature: (json['temperature'] as num?)?.toDouble(),
        tool_choice: json['tool_choice'],
        tools: (json['tools'] as List<dynamic>?)
            ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
            .toList(),
        top_logprobs: (json['top_logprobs'] as num?)?.toInt(),
        top_p: (json['top_p'] as num?)?.toDouble(),
        user: json['user'] as String?,
        web_search_options: json['web_search_options'] == null
            ? null
            : WebSearchOptions.fromJson(
                json['web_search_options'] as Map<String, dynamic>,
              ),
      )
      ..audio = json['audio'] == null
          ? null
          : Audio.fromJson(json['audio'] as Map<String, dynamic>);

Map<String, dynamic> _$ChatCompletionRequestToJson(
  ChatCompletionRequest instance,
) => <String, dynamic>{
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'model': instance.model,
  'audio': ?instance.audio?.toJson(),
  'frequency_penalty': ?instance.frequency_penalty,
  'function_call': ?instance.function_call,
  'functions': ?instance.functions?.map((e) => e.toJson()).toList(),
  'logit_bias': ?instance.logit_bias,
  'logprobs': ?instance.logprobs,
  'max_completion_tokens': ?instance.max_completion_tokens,
  'max_tokens': ?instance.max_tokens,
  'metadata': ?instance.metadata,
  'modalities': ?instance.modalities,
  'n': ?instance.n,
  'parallel_tool_calls': ?instance.parallel_tool_calls,
  'prediction': ?instance.prediction?.toJson(),
  'presence_penalty': ?instance.presence_penalty,
  'reasoning_effort': ?instance.reasoning_effort,
  'response_format': ?instance.response_format?.toJson(),
  'seed': ?instance.seed,
  'service_tier': ?instance.service_tier,
  'stop': ?instance.stop,
  'store': ?instance.store,
  'stream': ?instance.stream,
  'stream_options': ?instance.stream_options?.toJson(),
  'temperature': ?instance.temperature,
  'tool_choice': ?instance.tool_choice,
  'tools': ?instance.tools?.map((e) => e.toJson()).toList(),
  'top_logprobs': ?instance.top_logprobs,
  'top_p': ?instance.top_p,
  'user': ?instance.user,
  'web_search_options': ?instance.web_search_options?.toJson(),
};

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  role: json['role'] as String,
  content: json['content'],
  name: json['name'] as String?,
  function_call: json['function_call'] == null
      ? null
      : FunctionCalledModel.fromJson(
          json['function_call'] as Map<String, dynamic>,
        ),
  refusal: json['refusal'] as String?,
  tool_calls: (json['tool_calls'] as List<dynamic>?)
      ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
      .toList(),
  tool_call_id: json['tool_call_id'] as String?,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'role': instance.role,
  'content': ?instance.content,
  'name': ?instance.name,
  'function_call': ?instance.function_call?.toJson(),
  'refusal': ?instance.refusal,
  'tool_calls': ?instance.tool_calls?.map((e) => e.toJson()).toList(),
  'tool_call_id': ?instance.tool_call_id,
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
  'text': ?instance.text,
  'image_url': ?instance.image_url,
  'refusal': ?instance.refusal,
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
      'description': ?instance.description,
      'parameters': ?instance.parameters,
      'strict': ?instance.strict,
    };

Prediction _$PredictionFromJson(Map<String, dynamic> json) =>
    Prediction(type: json['type'] as String, content: json['content']);

Map<String, dynamic> _$PredictionToJson(Prediction instance) =>
    <String, dynamic>{'type': instance.type, 'content': ?instance.content};

ResponseFormat _$ResponseFormatFromJson(Map<String, dynamic> json) =>
    ResponseFormat(
      type: json['type'] as String,
      json_schema: json['json_schema'] == null
          ? null
          : JsonSchema.fromJson(json['json_schema'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ResponseFormatToJson(ResponseFormat instance) =>
    <String, dynamic>{
      'type': instance.type,
      'json_schema': ?instance.json_schema?.toJson(),
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
      'description': ?instance.description,
      'schema': ?instance.schema,
      'strict': ?instance.strict,
    };

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

WebSearchOptions _$WebSearchOptionsFromJson(Map<String, dynamic> json) =>
    WebSearchOptions(
      search_context_size: json['search_context_size'] as String?,
      user_location: json['user_location'] == null
          ? null
          : UserLocation.fromJson(
              json['user_location'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$WebSearchOptionsToJson(WebSearchOptions instance) =>
    <String, dynamic>{
      'search_context_size': ?instance.search_context_size,
      'user_location': ?instance.user_location?.toJson(),
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
      'approximate': instance.approximate.toJson(),
    };

Approximate _$ApproximateFromJson(Map<String, dynamic> json) => Approximate(
  city: json['city'] as String?,
  country: json['country'] as String?,
  region: json['region'] as String?,
  timezone: json['timezone'] as String?,
);

Map<String, dynamic> _$ApproximateToJson(Approximate instance) =>
    <String, dynamic>{
      'city': ?instance.city,
      'country': ?instance.country,
      'region': ?instance.region,
      'timezone': ?instance.timezone,
    };
