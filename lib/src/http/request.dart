import 'dart:convert';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import '../utils/logger.dart';

class RequestClient {
  static Future<Response> request(String method, String requestURL, Map<String, String> headers, String? requestBody, {Future<void> Function()? onRequestSent}) async {
    final Response response;
    try {
      if (method == 'GET') {
        response = await get(Uri.parse(requestURL), headers: headers);
      } else if (method == 'POST') {
        response = await post(Uri.parse(requestURL), headers: headers, body: requestBody);
      } else if (method == 'PUT') {
        response = await put(Uri.parse(requestURL), headers: headers, body: requestBody);
      } else if (method == 'DELETE') {
        response = await delete(Uri.parse(requestURL), headers: headers);
      } else {
        return Response('Method Not Allowed', 405);
      }
    } catch (e) {
      return Response('Proxy Error: $e', 500);
    }
    if(onRequestSent != null) onRequestSent();

    return response;
  }

  static Future<StreamedResponse> requestSSE(String method, String requestURL, Map<String, String> headers, String? requestBody, {Future<void> Function()? onRequestSent}) async {
    final client = Client();
    Request request = Request(method, Uri.parse(requestURL));
    request.headers.addAll(headers);
    logger.log(LogModule.adapter, "requestSSE", detail: "HTTP headers: ${jsonEncode(request.headers)}", level: Level.FINEST);
    if(requestBody != null) request.body = requestBody;
    final StreamedResponse streamedResponse = await client.send(request);
    if(onRequestSent != null) onRequestSent();
    return streamedResponse;
  }
}