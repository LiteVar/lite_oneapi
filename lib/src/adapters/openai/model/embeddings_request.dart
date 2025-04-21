import 'package:json_annotation/json_annotation.dart';

part 'embeddings_request.g.dart';

/// https://platform.openai.com/docs/api-reference/embeddings/create

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class EmbeddingsRequest {
  dynamic input; /// String or List<String> or List<int> or List<List<int>>
  String model;
  @JsonKey(includeIfNull: false) int? dimensions;
  @JsonKey(includeIfNull: false) String? response_format; /// `float` or `base64`
  @JsonKey(includeIfNull: false) String? user;

  EmbeddingsRequest({
    required this.input,
    required this.model,
    this.dimensions,
    this.response_format,
    this.user,
  });

  factory EmbeddingsRequest.fromJson(Map<String, dynamic> json) => _$EmbeddingsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EmbeddingsRequestToJson(this);
}