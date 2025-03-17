import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../adapters/adapter.dart';
import '../../adapters/openai/handler.dart';
import '../../api/meta.dart';

class OpenAIAdapter extends LLMAdapter{

  @override
  ResponseHandler get responseHandler => OpenAIResponseHandler();

  @override
  void init(Meta meta) {}

  @override
  String getRequestMethod(Request request, Meta meta) {
    return request.method;
  }

  @override
  String getRequestURL(Request request, Meta meta) {
    String urlPath = "/${request.url.path}";
    return "${meta.baseUrl}$urlPath";
  }

  @override
  Map<String, String> setupRequestHeaders(Request request, Meta meta) {
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
    Map<String, dynamic> requestBody = jsonDecode(meta.requestBody);
    return requestBody;
  }

  @override
  Future<Response> doRequest(Request request, Meta meta) async {
    return await doRequestHelper(request, meta);
  }

  @override
  Future<Response> doResponse(Response response, Meta meta) async {
    if(meta.isStream) {
      return responseHandler.handleStream(response);
    } else {
      return responseHandler.handle(response);
    }
  }
}

