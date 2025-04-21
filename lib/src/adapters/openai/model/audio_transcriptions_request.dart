import 'package:json_annotation/json_annotation.dart';

part 'audio_transcriptions_request.g.dart';

/// https://platform.openai.com/docs/api-reference/audio/createTranscription

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class AudioTranscriptionsRequest {
  String file;
  String model;
  String? language;
  String? prompt;
  String? response_format; /// `json`, `text`, `srt`, `verbose_json`, or `vtt`
  double? temperature;
  List<String>? timestamp_granularities;

  AudioTranscriptionsRequest({
    required this.file,
    required this.model,
    this.language,
    this.prompt,
    this.response_format,
    this.temperature,
    this.timestamp_granularities,
  });

  factory AudioTranscriptionsRequest.fromJson(Map<String, dynamic> json) => _$AudioTranscriptionsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AudioTranscriptionsRequestToJson(this);
}