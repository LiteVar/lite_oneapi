import 'package:shelf/shelf.dart';

import '../adapter.dart';

class OpenAIResponseHandler implements ResponseHandler {
  @override
  Response handle(Response response) {
    return response;
  }

  @override
  Response handleStream(Response response) {
    return response;
  }
}