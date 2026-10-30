// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embeddings_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmbeddingsResponse _$EmbeddingsResponseFromJson(Map<String, dynamic> json) =>
    EmbeddingsResponse(
      embedding:
          (json['embedding'] as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList(),
      index: (json['index'] as num).toInt(),
      object: json['object'] as String,
    );

Map<String, dynamic> _$EmbeddingsResponseToJson(EmbeddingsResponse instance) =>
    <String, dynamic>{
      'embedding': instance.embedding,
      'index': instance.index,
      'object': instance.object,
    };
