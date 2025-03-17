import 'package:json_annotation/json_annotation.dart';

part 'embeddings_response.g.dart';

/// https://platform.openai.com/docs/api-reference/embeddings/object

@JsonSerializable()
class EmbeddingsResponse {
  List<double> embedding;
  int index;
  String object;

  EmbeddingsResponse({
    required this.embedding,
    required this.index,
    required this.object,
  });

  factory EmbeddingsResponse.fromJson(Map<String, dynamic> json) => _$EmbeddingsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EmbeddingsResponseToJson(this);
}