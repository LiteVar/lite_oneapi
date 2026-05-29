import 'dart:convert';

import 'package:shelf/shelf.dart';
import '../../api/meta.dart';
import '../adapter.dart';
import '../openai/adapter.dart';
import 'handler.dart';

class MiniMaxAdapter extends OpenAIAdapter {
  @override
  ResponseHandler get responseHandler => MiniMaxResponseHandler();

  @override
  Map<String, String> setupRequestHeaders(Request request, Meta meta) {
    Map<String, String> headers = {};
    headers.addAll(request.headers);
    headers["Accept"] = meta.isStream ? "text/event-stream" : "application/json";
    return headers;
  }

  @override
  Future<Map<String, dynamic>> convertRequest(Request request, Meta meta) async {
    final Map<String, dynamic> requestBody = jsonDecode(meta.requestBody);
    requestBody.putIfAbsent("reasoning_split", () => true);
    _mapReasoningContentToReasoningDetails(requestBody);
    return requestBody;
  }

  void _mapReasoningContentToReasoningDetails(Map<String, dynamic> requestBody) {
    final dynamic messages = requestBody["messages"];
    if (messages is! List) {
      return;
    }

    for (final dynamic message in messages) {
      if (message is! Map<String, dynamic>) {
        continue;
      }

      if (message.containsKey("reasoning_details")) {
        continue;
      }

      final dynamic reasoningContent = message["reasoning_content"];
      if (reasoningContent is String && reasoningContent.isNotEmpty) {
        message["reasoning_details"] = [
          {"text": reasoningContent},
        ];
      }
    }
  }
}
