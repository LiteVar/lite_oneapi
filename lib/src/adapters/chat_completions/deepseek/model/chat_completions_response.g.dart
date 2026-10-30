// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_completions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatCompletionsResponse _$ChatCompletionsResponseFromJson(
  Map<String, dynamic> json,
) => ChatCompletionsResponse(
  id: json['id'] as String,
  choices:
      (json['choices'] as List<dynamic>)
          .map((e) => Choice.fromJson(e as Map<String, dynamic>))
          .toList(),
  created: (json['created'] as num).toInt(),
  model: json['model'] as String,
  system_fingerprint: json['system_fingerprint'] as String,
  object: json['object'] as String,
  usage: Usage.fromJson(json['usage'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatCompletionsResponseToJson(
  ChatCompletionsResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'choices': instance.choices.map((e) => e.toJson()).toList(),
  'created': instance.created,
  'model': instance.model,
  'system_fingerprint': instance.system_fingerprint,
  'object': instance.object,
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
  annotations:
      (json['annotations'] as List<dynamic>)
          .map((e) => Annotation.fromJson(e as Map<String, dynamic>))
          .toList(),
  audio:
      json['audio'] == null
          ? null
          : Audio.fromJson(json['audio'] as Map<String, dynamic>),
  function_call:
      json['function_call'] == null
          ? null
          : FunctionModelOld.fromJson(
            json['function_call'] as Map<String, dynamic>,
          ),
  name: json['name'] as String?,
  tool_calls:
      (json['tool_calls'] as List<dynamic>?)
          ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  if (instance.content case final value?) 'content': value,
  if (instance.refusal case final value?) 'refusal': value,
  'role': instance.role,
  'annotations': instance.annotations.map((e) => e.toJson()).toList(),
  if (instance.audio?.toJson() case final value?) 'audio': value,
  if (instance.function_call?.toJson() case final value?)
    'function_call': value,
  if (instance.name case final value?) 'name': value,
  if (instance.tool_calls?.map((e) => e.toJson()).toList() case final value?)
    'tool_calls': value,
};

Annotation _$AnnotationFromJson(Map<String, dynamic> json) => Annotation(
  type: json['type'] as String,
  url_citation: UrlCitation.fromJson(
    json['url_citation'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$AnnotationToJson(Annotation instance) =>
    <String, dynamic>{
      'type': instance.type,
      'url_citation': instance.url_citation.toJson(),
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

UrlCitation _$UrlCitationFromJson(Map<String, dynamic> json) => UrlCitation(
  end_index: (json['end_index'] as num).toInt(),
  start_index: (json['start_index'] as num).toInt(),
  title: json['title'] as String,
  url: json['url'] as String,
);

Map<String, dynamic> _$UrlCitationToJson(UrlCitation instance) =>
    <String, dynamic>{
      'end_index': instance.end_index,
      'start_index': instance.start_index,
      'title': instance.title,
      'url': instance.url,
    };

FunctionModelOld _$FunctionModelOldFromJson(Map<String, dynamic> json) =>
    FunctionModelOld(
      name: json['name'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$FunctionModelOldToJson(FunctionModelOld instance) =>
    <String, dynamic>{'name': instance.name, 'arguments': instance.arguments};

ToolCall _$ToolCallFromJson(Map<String, dynamic> json) =>
    ToolCall(id: json['id'] as String, type: json['type'] as String);

Map<String, dynamic> _$ToolCallToJson(ToolCall instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
};

Usage _$UsageFromJson(Map<String, dynamic> json) => Usage(
  completion_tokens: (json['completion_tokens'] as num).toInt(),
  prompt_tokens: (json['prompt_tokens'] as num).toInt(),
  prompt_cache_hit_tokens: (json['prompt_cache_hit_tokens'] as num).toInt(),
  prompt_cache_miss_tokens: (json['prompt_cache_miss_tokens'] as num).toInt(),
  total_tokens: (json['total_tokens'] as num).toInt(),
  completion_tokens_details: CompletionTokensDetails.fromJson(
    json['completion_tokens_details'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$UsageToJson(Usage instance) => <String, dynamic>{
  'completion_tokens': instance.completion_tokens,
  'prompt_tokens': instance.prompt_tokens,
  'prompt_cache_hit_tokens': instance.prompt_cache_hit_tokens,
  'prompt_cache_miss_tokens': instance.prompt_cache_miss_tokens,
  'total_tokens': instance.total_tokens,
  'completion_tokens_details': instance.completion_tokens_details.toJson(),
};

CompletionTokensDetails _$CompletionTokensDetailsFromJson(
  Map<String, dynamic> json,
) => CompletionTokensDetails(
  reasoning_tokens: (json['reasoning_tokens'] as num).toInt(),
);

Map<String, dynamic> _$CompletionTokensDetailsToJson(
  CompletionTokensDetails instance,
) => <String, dynamic>{'reasoning_tokens': instance.reasoning_tokens};
