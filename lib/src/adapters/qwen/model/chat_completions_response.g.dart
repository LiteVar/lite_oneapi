// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_completions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatCompletionsResponse _$ChatCompletionsResponseFromJson(
  Map<String, dynamic> json,
) => ChatCompletionsResponse(
  choices:
      (json['choices'] as List<dynamic>)
          .map((e) => Choice.fromJson(e as Map<String, dynamic>))
          .toList(),
  created: (json['created'] as num).toInt(),
  id: json['id'] as String,
  model: json['model'] as String,
  object: json['object'] as String,
  service_tier: json['service_tier'] as String?,
  system_fingerprint: json['system_fingerprint'] as String,
  usage: Usage.fromJson(json['usage'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatCompletionsResponseToJson(
  ChatCompletionsResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'choices': instance.choices.map((e) => e.toJson()).toList(),
  'created': instance.created,
  'model': instance.model,
  'object': instance.object,
  if (instance.service_tier case final value?) 'service_tier': value,
  'system_fingerprint': instance.system_fingerprint,
  'usage': instance.usage.toJson(),
};

Choice _$ChoiceFromJson(Map<String, dynamic> json) => Choice(
  finish_reason: json['finish_reason'] as String,
  index: json['index'] as String,
  logprobs:
      json['logprobs'] == null
          ? null
          : Logprobs.fromJson(json['logprobs'] as Map<String, dynamic>),
  message: Message.fromJson(json['message'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChoiceToJson(Choice instance) => <String, dynamic>{
  'finish_reason': instance.finish_reason,
  'index': instance.index,
  if (instance.logprobs?.toJson() case final value?) 'logprobs': value,
  'message': instance.message.toJson(),
};

Logprobs _$LogprobsFromJson(Map<String, dynamic> json) => Logprobs(
  content:
      (json['content'] as List<dynamic>?)
          ?.map((e) => Logprob.fromJson(e as Map<String, dynamic>))
          .toList(),
  refusal:
      (json['refusal'] as List<dynamic>?)
          ?.map((e) => Logprob.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$LogprobsToJson(Logprobs instance) => <String, dynamic>{
  if (instance.content?.map((e) => e.toJson()).toList() case final value?)
    'content': value,
  if (instance.refusal?.map((e) => e.toJson()).toList() case final value?)
    'refusal': value,
};

Logprob _$LogprobFromJson(Map<String, dynamic> json) => Logprob(
  bytes:
      (json['bytes'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
  logprob: (json['logprob'] as num).toInt(),
  token: json['token'] as String,
  top_logprobs:
      (json['top_logprobs'] as List<dynamic>)
          .map((e) => TopLogrob.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$LogprobToJson(Logprob instance) => <String, dynamic>{
  if (instance.bytes case final value?) 'bytes': value,
  'logprob': instance.logprob,
  'token': instance.token,
  'top_logprobs': instance.top_logprobs.map((e) => e.toJson()).toList(),
};

TopLogrob _$TopLogrobFromJson(Map<String, dynamic> json) => TopLogrob(
  bytes:
      (json['bytes'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
  logprob: (json['logprob'] as num).toInt(),
  token: json['token'] as String,
  top_logprobs:
      (json['top_logprobs'] as List<dynamic>)
          .map((e) => TopLogrob.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$TopLogrobToJson(TopLogrob instance) => <String, dynamic>{
  if (instance.bytes case final value?) 'bytes': value,
  'logprob': instance.logprob,
  'token': instance.token,
  'top_logprobs': instance.top_logprobs.map((e) => e.toJson()).toList(),
};

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  content: json['content'] as String?,
  refusal: json['refusal'] as String?,
  role: json['role'] as String,
  audio:
      json['audio'] == null
          ? null
          : Audio.fromJson(json['audio'] as Map<String, dynamic>),
  function_call:
      json['function_call'] == null
          ? null
          : FunctionCalledModel.fromJson(
            json['function_call'] as Map<String, dynamic>,
          ),
  tool_calls:
      (json['tool_calls'] as List<dynamic>?)
          ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  if (instance.content case final value?) 'content': value,
  if (instance.refusal case final value?) 'refusal': value,
  'role': instance.role,
  if (instance.audio?.toJson() case final value?) 'audio': value,
  if (instance.function_call?.toJson() case final value?)
    'function_call': value,
  if (instance.tool_calls?.map((e) => e.toJson()).toList() case final value?)
    'tool_calls': value,
};

Audio _$AudioFromJson(Map<String, dynamic> json) => Audio(
  data: json['data'] as String,
  expires_at: (json['expires_at'] as num).toInt(),
  id: json['id'] as String,
  transcript: json['transcript'] as String,
);

Map<String, dynamic> _$AudioToJson(Audio instance) => <String, dynamic>{
  'data': instance.data,
  'expires_at': instance.expires_at,
  'id': instance.id,
  'transcript': instance.transcript,
};

FunctionCalledModel _$FunctionCalledModelFromJson(Map<String, dynamic> json) =>
    FunctionCalledModel(
      name: json['name'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
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

Usage _$UsageFromJson(Map<String, dynamic> json) => Usage(
  completion_tokens: (json['completion_tokens'] as num).toInt(),
  prompt_tokens: (json['prompt_tokens'] as num).toInt(),
  total_tokens: (json['total_tokens'] as num).toInt(),
  completion_tokens_details:
      json['completion_tokens_details'] == null
          ? null
          : CompletionTokensDetails.fromJson(
            json['completion_tokens_details'] as Map<String, dynamic>,
          ),
  prompt_tokens_details: PromptTokensDetails.fromJson(
    json['prompt_tokens_details'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$UsageToJson(Usage instance) => <String, dynamic>{
  'completion_tokens': instance.completion_tokens,
  'prompt_tokens': instance.prompt_tokens,
  'total_tokens': instance.total_tokens,
  if (instance.completion_tokens_details?.toJson() case final value?)
    'completion_tokens_details': value,
  'prompt_tokens_details': instance.prompt_tokens_details.toJson(),
};

CompletionTokensDetails _$CompletionTokensDetailsFromJson(
  Map<String, dynamic> json,
) => CompletionTokensDetails(
  accepted_prediction_tokens:
      (json['accepted_prediction_tokens'] as num).toInt(),
  audio_tokens: (json['audio_tokens'] as num).toInt(),
  reasoning_tokens: (json['reasoning_tokens'] as num).toInt(),
  rejected_prediction_tokens:
      (json['rejected_prediction_tokens'] as num).toInt(),
);

Map<String, dynamic> _$CompletionTokensDetailsToJson(
  CompletionTokensDetails instance,
) => <String, dynamic>{
  'accepted_prediction_tokens': instance.accepted_prediction_tokens,
  'audio_tokens': instance.audio_tokens,
  'reasoning_tokens': instance.reasoning_tokens,
  'rejected_prediction_tokens': instance.rejected_prediction_tokens,
};

PromptTokensDetails _$PromptTokensDetailsFromJson(Map<String, dynamic> json) =>
    PromptTokensDetails(
      audio_tokens: (json['audio_tokens'] as num?)?.toInt(),
      cached_tokens: (json['cached_tokens'] as num).toInt(),
    );

Map<String, dynamic> _$PromptTokensDetailsToJson(
  PromptTokensDetails instance,
) => <String, dynamic>{
  if (instance.audio_tokens case final value?) 'audio_tokens': value,
  'cached_tokens': instance.cached_tokens,
};
