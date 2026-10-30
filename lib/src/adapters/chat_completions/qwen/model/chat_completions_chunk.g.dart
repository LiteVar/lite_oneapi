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
  system_fingerprint: json['system_fingerprint'] as String?,
  usage:
      json['usage'] == null
          ? null
          : Usage.fromJson(json['usage'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatCompletionsChunkToJson(
  ChatCompletionsChunk instance,
) => <String, dynamic>{
  'id': instance.id,
  'choices': instance.choices.map((e) => e.toJson()).toList(),
  'created': instance.created,
  'model': instance.model,
  'object': instance.object,
  if (instance.service_tier case final value?) 'service_tier': value,
  if (instance.system_fingerprint case final value?)
    'system_fingerprint': value,
  if (instance.usage?.toJson() case final value?) 'usage': value,
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

Delta _$DeltaFromJson(Map<String, dynamic> json) =>
    Delta(
        content: json['content'] as String,
        reasoning_content: json['reasoning_content'] as String,
        role: json['role'] as String,
      )
      ..function_call =
          json['function_call'] == null
              ? null
              : FunctionCalledModel.fromJson(
                json['function_call'] as Map<String, dynamic>,
              )
      ..refusal = json['refusal'] as String?
      ..tools_calls =
          (json['tools_calls'] as List<dynamic>?)
              ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
              .toList();

Map<String, dynamic> _$DeltaToJson(Delta instance) => <String, dynamic>{
  'content': instance.content,
  'reasoning_content': instance.reasoning_content,
  if (instance.function_call?.toJson() case final value?)
    'function_call': value,
  if (instance.refusal case final value?) 'refusal': value,
  'role': instance.role,
  if (instance.tools_calls?.map((e) => e.toJson()).toList() case final value?)
    'tools_calls': value,
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
) => CompletionTokensDetails(text_tokens: (json['text_tokens'] as num).toInt());

Map<String, dynamic> _$CompletionTokensDetailsToJson(
  CompletionTokensDetails instance,
) => <String, dynamic>{'text_tokens': instance.text_tokens};

PromptTokensDetails _$PromptTokensDetailsFromJson(Map<String, dynamic> json) =>
    PromptTokensDetails(
      audio_tokens: (json['audio_tokens'] as num?)?.toInt(),
      text_tokens: (json['text_tokens'] as num?)?.toInt(),
      video_tokens: (json['video_tokens'] as num?)?.toInt(),
      image_tokens: (json['image_tokens'] as num?)?.toInt(),
      cached_tokens: (json['cached_tokens'] as num).toInt(),
    );

Map<String, dynamic> _$PromptTokensDetailsToJson(
  PromptTokensDetails instance,
) => <String, dynamic>{
  if (instance.audio_tokens case final value?) 'audio_tokens': value,
  if (instance.text_tokens case final value?) 'text_tokens': value,
  if (instance.video_tokens case final value?) 'video_tokens': value,
  if (instance.image_tokens case final value?) 'image_tokens': value,
  'cached_tokens': instance.cached_tokens,
};
