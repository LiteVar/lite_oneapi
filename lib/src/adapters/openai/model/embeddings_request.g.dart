// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embeddings_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmbeddingsRequest _$EmbeddingsRequestFromJson(Map<String, dynamic> json) =>
    EmbeddingsRequest(
      input: json['input'],
      model: json['model'] as String,
      dimensions: (json['dimensions'] as num?)?.toInt(),
      response_format: json['response_format'] as String?,
      user: json['user'] as String?,
    );

Map<String, dynamic> _$EmbeddingsRequestToJson(EmbeddingsRequest instance) =>
    <String, dynamic>{
      if (instance.input case final value?) 'input': value,
      'model': instance.model,
      if (instance.dimensions case final value?) 'dimensions': value,
      if (instance.response_format case final value?) 'response_format': value,
      if (instance.user case final value?) 'user': value,
    };
