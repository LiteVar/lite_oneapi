import 'package:shelf/shelf.dart';

import '../adapter.dart';
import '../streaming_response_normalizer.dart';

class OpenAIResponseHandler implements ResponseHandler {
  @override
  Response handle(Response response) {
    return response;
  }

  @override
  Response handleStream(Response response) {
    return response.change(
      body: StreamingResponseNormalizer.normalizeSseStream(response.read()),
      headers: {
        ...response.headers,
        'content-type': 'text/event-stream',
      },
    );
  }
}
