// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_transcriptions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioTranscriptionsResponse _$AudioTranscriptionsResponseFromJson(
  Map<String, dynamic> json,
) => AudioTranscriptionsResponse(text: json['text'] as String);

Map<String, dynamic> _$AudioTranscriptionsResponseToJson(
  AudioTranscriptionsResponse instance,
) => <String, dynamic>{'text': instance.text};

AudioTranscriptionsVerboseResponse _$AudioTranscriptionsVerboseResponseFromJson(
  Map<String, dynamic> json,
) => AudioTranscriptionsVerboseResponse(
  duration: (json['duration'] as num).toDouble(),
  language: json['language'] as String,
  segments:
      (json['segments'] as List<dynamic>)
          .map((e) => Segment.fromJson(e as Map<String, dynamic>))
          .toList(),
  text: json['text'] as String,
  words:
      (json['words'] as List<dynamic>)
          .map((e) => Word.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$AudioTranscriptionsVerboseResponseToJson(
  AudioTranscriptionsVerboseResponse instance,
) => <String, dynamic>{
  'duration': instance.duration,
  'language': instance.language,
  'segments': instance.segments.map((e) => e.toJson()).toList(),
  'text': instance.text,
  'words': instance.words.map((e) => e.toJson()).toList(),
};

Segment _$SegmentFromJson(Map<String, dynamic> json) => Segment(
  avg_logprob: (json['avg_logprob'] as num).toDouble(),
  compression_ratio: (json['compression_ratio'] as num).toDouble(),
  end: (json['end'] as num).toDouble(),
  id: (json['id'] as num).toInt(),
  no_speech_prob: (json['no_speech_prob'] as num).toDouble(),
  seek: (json['seek'] as num).toInt(),
  start: (json['start'] as num).toDouble(),
  temperature: (json['temperature'] as num).toDouble(),
  text: json['text'] as String,
  tokens:
      (json['tokens'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
);

Map<String, dynamic> _$SegmentToJson(Segment instance) => <String, dynamic>{
  'avg_logprob': instance.avg_logprob,
  'compression_ratio': instance.compression_ratio,
  'end': instance.end,
  'id': instance.id,
  'no_speech_prob': instance.no_speech_prob,
  'seek': instance.seek,
  'start': instance.start,
  'temperature': instance.temperature,
  'text': instance.text,
  'tokens': instance.tokens,
};

Word _$WordFromJson(Map<String, dynamic> json) => Word(
  end: (json['end'] as num).toDouble(),
  start: (json['start'] as num).toDouble(),
  word: json['word'] as String,
);

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
  'end': instance.end,
  'start': instance.start,
  'word': instance.word,
};
