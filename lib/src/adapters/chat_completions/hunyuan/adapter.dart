import 'package:shelf/shelf.dart';

import '../../../api/meta.dart';
import '../../../define.dart';
import '../openai/adapter.dart';

class HunyuanAdapter extends OpenAIAdapter {
  @override
  String get providerName => 'hunyuan';

  @override
  Future<Map<String, dynamic>> convertRequest(
      Request request, Meta meta) async {
    final Map<String, dynamic> body = await super.convertRequest(request, meta);
    if (meta.mode != RelayMode.ChatCompletions) return body;

    final dynamic messages = body['messages'];
    if (messages is List) {
      body['messages'] = messages.map((dynamic rawMessage) {
        if (rawMessage is! Map) return rawMessage;
        final Map<String, dynamic> message =
            Map<String, dynamic>.from(rawMessage);
        if (message['role'] == 'developer') message['role'] = 'system';
        return message;
      }).toList(growable: false);
    }
    return body;
  }
}
