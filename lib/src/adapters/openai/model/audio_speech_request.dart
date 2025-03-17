import 'package:json_annotation/json_annotation.dart';

part 'audio_speech_request.g.dart';

/// https://platform.openai.com/docs/api-reference/audio/createSpeech

@JsonSerializable()
class AudioSpeechRequest {
  String input;
  String model;
  String voice; /// `alloy`, `ash`, `coral`, `echo`, `fable`, `onyx`, `nova`, `sage` and `shimmer`
  @JsonKey(includeIfNull: false) String? response_format; /// `mp3`, `opus`, `aac`, `flac`, `wav`, and `pcm`
  @JsonKey(includeIfNull: false) double? speed;  /// 0.25 to 4.0

  AudioSpeechRequest({
    required this.input,
    required this.model,
    required this.voice,
    this.response_format,
    this.speed,
  });

  factory AudioSpeechRequest.fromJson(Map<String, dynamic> json) => _$AudioSpeechRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AudioSpeechRequestToJson(this);
}