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
  system_fingerprint: json['system_fingerprint'] as String,
  object: json['object'] as String,
);

Map<String, dynamic> _$ChatCompletionsChunkToJson(
  ChatCompletionsChunk instance,
) => <String, dynamic>{
  'id': instance.id,
  'choices': instance.choices.map((e) => e.toJson()).toList(),
  'created': instance.created,
  'model': instance.model,
  'system_fingerprint': instance.system_fingerprint,
  'object': instance.object,
};

Choice _$ChoiceFromJson(Map<String, dynamic> json) => Choice(
  delta: Delta.fromJson(json['delta'] as Map<String, dynamic>),
  finish_reason: json['finish_reason'] as String?,
  index: json['index'] as String,
);

Map<String, dynamic> _$ChoiceToJson(Choice instance) => <String, dynamic>{
  'delta': instance.delta.toJson(),
  if (instance.finish_reason case final value?) 'finish_reason': value,
  'index': instance.index,
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
