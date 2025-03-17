import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../adapters/adapter.dart';
import '../../adapters/openai/handler.dart';
import '../../api/meta.dart';
import '../openai/adapter.dart';
import 'handler.dart';

class NewLLMAdapter extends OpenAIAdapter {

  @override
  ResponseHandler get responseHandler => NewLLMResponseHandler();

  @override
  void init(Meta meta) {
    /// add init code here for your need
  }

  @override
  String getRequestMethod(Request request, Meta meta) {
    /// add request method convert here
    /// such as GET to POST
    /// for your need
    return request.method;
  }

  @override
  String getRequestURL(Request request, Meta meta) {
    /// add request url convert here
    /// such as "/v1/chat/completions" to "/api/v2/chat/completions"
    /// for your need
    String urlPath = "/${request.url.path}";
    return "${meta.baseUrl}$urlPath";
  }

  @override
  Map<String, String> setupRequestHeaders(Request request, Meta meta) {
    /// add request headers convert here for your need
    Map<String, String> headers = {};
    headers.addAll(request.headers);
    if(meta.isStream) {
      if(headers["Accept"] != "text/event-stream")  headers["Accept"] = "text/event-stream";
      if(headers["X-DashScope-SSE"] != "enable" ) headers["X-DashScope-SSE"] = "enable";
    } else {
      if(headers["Accept"] != "application/json")  headers["Accept"] = "application/json";
    }

    return headers;
  }

  @override
  Future<Map<String, dynamic>> convertRequest(Request request, Meta meta) async {
    /// add request body convert here for your need
    Map<String, dynamic> requestBody = jsonDecode(meta.requestBody);
    return requestBody;
  }

  @override
  Future<Response> doRequest(Request request, Meta meta) async {
    /// add some code before do request here
    return await doRequestHelper(request, meta);
  }

  @override
  Future<Response> doResponse(Response response, Meta meta) async {
    /// add some code before do response here
    if(meta.isStream) {
      return responseHandler.handleStream(response);
    } else {
      return responseHandler.handle(response);
    }
  }
}

