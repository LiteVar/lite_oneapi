// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_completions_chunk.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatCompletionsChunk _$ChatCompletionsChunkFromJson(
  Map<String, dynamic> json,
) => ChatCompletionsChunk(
  id: json['id'] as String,
  choices:
      (json['choices'] as List<dynamic>)
          .map((e) => Choice.fromJson(e as Map<String, dynamic>))
          .toList(),
  created: (json['created'] as num).toInt(),
  model: json['model'] as String,
  object: json['object'] as String,
  service_tier: json['service_tier'] as String?,
  system_fingerprint: json['system_fingerprint'] as String,
  usage:
      json['usage'] == null
          ? null
          : Usage.fromJson(json['usage'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatCompletionsChunkToJson(
  ChatCompletionsChunk instance,
) => <String, dynamic>{
  'choices': instance.choices.map((e) => e.toJson()).toList(),
  'created': instance.created,
  'id': instance.id,
  'model': instance.model,
  'object': instance.object,
  if (instance.service_tier case final value?) 'service_tier': value,
  'system_fingerprint': instance.system_fingerprint,
  if (instance.usage?.toJson() case final value?) 'usage': value,
};

Choice _$ChoiceFromJson(Map<String, dynamic> json) => Choice(
  delta: Delta.fromJson(json['delta'] as Map<String, dynamic>),
  finish_reason: json['finish_reason'] as String?,
  index: json['index'] as String,
  logprobs:
      json['logprobs'] == null
          ? null
          : Logprobs.fromJson(json['logprobs'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChoiceToJson(Choice instance) => <String, dynamic>{
  'delta': instance.delta.toJson(),
  if (instance.finish_reason case final value?) 'finish_reason': value,
  'index': instance.index,
  if (instance.logprobs?.toJson() case final value?) 'logprobs': value,
};

Delta _$DeltaFromJson(Map<String, dynamic> json) => Delta(
  content: json['content'] as String,
  reasoning_content: json['reasoning_content'] as String,
  role: json['role'] as String,
);

Map<String, dynamic> _$DeltaToJson(Delta instance) => <String, dynamic>{
  'content': instance.content,
  'reasoning_content': instance.reasoning_content,
  'role': instance.role,
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

Usage _$UsageFromJson(Map<String, dynamic> json) => Usage(
  completion_tokens: (json['completion_tokens'] as num).toInt(),
  prompt_tokens: (json['prompt_tokens'] as num).toInt(),
  total_tokens: (json['total_tokens'] as num).toInt(),
);

Map<String, dynamic> _$UsageToJson(Usage instance) => <String, dynamic>{
  'completion_tokens': instance.completion_tokens,
  'prompt_tokens': instance.prompt_tokens,
  'total_tokens': instance.total_tokens,
};
