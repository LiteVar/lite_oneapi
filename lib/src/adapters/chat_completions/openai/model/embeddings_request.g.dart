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
      'input': ?instance.input,
      'model': instance.model,
      'dimensions': ?instance.dimensions,
      'response_format': ?instance.response_format,
      'user': ?instance.user,
    };
