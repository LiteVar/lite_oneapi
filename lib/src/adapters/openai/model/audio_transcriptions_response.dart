import 'package:json_annotation/json_annotation.dart';

part 'audio_transcriptions_response.g.dart';

/// https://platform.openai.com/docs/api-reference/audio/json-object

@JsonSerializable()
class AudioTranscriptionsResponse {
  String text;

  AudioTranscriptionsResponse({
    required this.text,
  });

  factory AudioTranscriptionsResponse.fromJson(Map<String, dynamic> json) => _$AudioTranscriptionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AudioTranscriptionsResponseToJson(this);
}

@JsonSerializable()
class AudioTranscriptionsVerboseResponse {
  double duration;
  String language;
  List<Segment> segments;
  String text;
  List<Word> words;

  AudioTranscriptionsVerboseResponse({
    required this.duration,
    required this.language,
    required this.segments,
    required this.text,
    required this.words,
  });

  factory AudioTranscriptionsVerboseResponse.fromJson(Map<String, dynamic> json) => _$AudioTranscriptionsVerboseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AudioTranscriptionsVerboseResponseToJson(this);
}

@JsonSerializable()
class Segment {
  double avg_logprob;
  double compression_ratio;
  double end;
  int id;
  double no_speech_prob;
  int seek;
  double start;
  double temperature;
  String text;
  List<int> tokens;

  Segment({
    required this.avg_logprob,
    required this.compression_ratio,
    required this.end,
    required this.id,
    required this.no_speech_prob,
    required this.seek,
    required this.start,
    required this.temperature,
    required this.text,
    required this.tokens,
  });

  factory Segment.fromJson(Map<String, dynamic> json) => _$SegmentFromJson(json);

  Map<String, dynamic> toJson() => _$SegmentToJson(this);
}

@JsonSerializable()
class Word {
  double end;
  double start;
  String word;

  Word({
    required this.end,
    required this.start,
    required this.word,
  });

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);

  Map<String, dynamic> toJson() => _$WordToJson(this);
}