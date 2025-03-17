import 'package:json_annotation/json_annotation.dart';

part 'audio_transcriptions_request.g.dart';

/// https://platform.openai.com/docs/api-reference/audio/createTranscription

@JsonSerializable()
class AudioTranscriptionsRequest {
  String file;
  String model;
  @JsonKey(includeIfNull: false) String? language;
  @JsonKey(includeIfNull: false) String? prompt;
  @JsonKey(includeIfNull: false) String? response_format; /// `json`, `text`, `srt`, `verbose_json`, or `vtt`
  @JsonKey(includeIfNull: false) double? temperature;
  @JsonKey(includeIfNull: false) List<String>? timestamp_granularities;

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