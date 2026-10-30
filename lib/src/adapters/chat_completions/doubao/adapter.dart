import 'package:shelf/shelf.dart';

import '../../../api/meta.dart';
import '../../exception.dart';
import '../openai/adapter.dart';

class DoubaoAdapter extends OpenAIAdapter {
  @override
  String get providerName => 'doubao';

  @override
  Future<Map<String, dynamic>> convertRequest(
      Request request, Meta meta) async {
    final Map<String, dynamic> body = await super.convertRequest(request, meta);
    if (body['max_tokens'] != null && body['max_completion_tokens'] != null) {
      throw UnsupportedRequestException(
        'Doubao does not allow `max_tokens` and `max_completion_tokens` in the same request.',
      );
    }
    return body;
  }
}
