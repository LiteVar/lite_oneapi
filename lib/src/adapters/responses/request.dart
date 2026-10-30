import '../exception.dart';

/// An OpenAI Responses request kept independent from Chat Completions and
/// Anthropic Messages. Unknown fields are preserved for provider extensions.
class ResponsesRequest {
  final Map<String, dynamic> fields;

  const ResponsesRequest(this.fields);

  factory ResponsesRequest.fromJson(Map<String, dynamic> json) {
    final dynamic model = json['model'];
    if (model is! String || model.isEmpty) {
      throw UnsupportedRequestException('`model` must be a non-empty string.');
    }
    if (!json.containsKey('input')) {
      throw UnsupportedRequestException('`input` is required for Responses.');
    }
    final dynamic input = json['input'];
    if (input != null && input is! String && input is! List) {
      throw UnsupportedRequestException(
        '`input` must be a string, an array, or null.',
      );
    }
    if (json['instructions'] != null && json['instructions'] is! String) {
      throw UnsupportedRequestException('`instructions` must be a string.');
    }
    if (json['stream'] != null && json['stream'] is! bool) {
      throw UnsupportedRequestException('`stream` must be a boolean.');
    }
    if (json['tools'] != null && json['tools'] is! List) {
      throw UnsupportedRequestException('`tools` must be an array.');
    }
    return ResponsesRequest(Map<String, dynamic>.from(json));
  }

  String get model => fields['model'] as String;
  bool get stream => fields['stream'] == true;

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(fields);
}
