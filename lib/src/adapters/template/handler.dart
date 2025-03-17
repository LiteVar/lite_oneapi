import 'package:shelf/shelf.dart';

import '../adapter.dart';

class NewLLMResponseHandler implements ResponseHandler {
  @override
  Response handle(Response response) {
    /// add some code convert response json for your need
    return response;
  }

  @override
  Response handleStream(Response response) {
    /// add some code convert response chunk for your need
    return response;
  }
}