// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_transcriptions_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioTranscriptionsRequest _$AudioTranscriptionsRequestFromJson(
  Map<String, dynamic> json,
) => AudioTranscriptionsRequest(
  file: json['file'] as String,
  model: json['model'] as String,
  language: json['language'] as String?,
  prompt: json['prompt'] as String?,
  response_format: json['response_format'] as String?,
  temperature: (json['temperature'] as num?)?.toDouble(),
  timestamp_granularities:
      (json['timestamp_granularities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$AudioTranscriptionsRequestToJson(
  AudioTranscriptionsRequest instance,
) => <String, dynamic>{
  'file': instance.file,
  'model': instance.model,
  if (instance.language case final value?) 'language': value,
  if (instance.prompt case final value?) 'prompt': value,
  if (instance.response_format case final value?) 'response_format': value,
  if (instance.temperature case final value?) 'temperature': value,
  if (instance.timestamp_granularities case final value?)
    'timestamp_granularities': value,
};
