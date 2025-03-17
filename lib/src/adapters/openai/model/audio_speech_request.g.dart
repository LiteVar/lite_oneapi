// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_speech_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioSpeechRequest _$AudioSpeechRequestFromJson(Map<String, dynamic> json) =>
    AudioSpeechRequest(
      input: json['input'] as String,
      model: json['model'] as String,
      voice: json['voice'] as String,
      response_format: json['response_format'] as String?,
      speed: (json['speed'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AudioSpeechRequestToJson(AudioSpeechRequest instance) =>
    <String, dynamic>{
      'input': instance.input,
      'model': instance.model,
      'voice': instance.voice,
      if (instance.response_format case final value?) 'response_format': value,
      if (instance.speed case final value?) 'speed': value,
    };
