import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import '../../lite_oneapi.dart';
import '../http/request.dart';

class ApiClient {
  static Future<Response> request(String method, String requestURL,
      Map<String, String> headers, String? requestBody,
      {Future<void> Function()? onRequestSent}) async {
    http.Response httpResponse = await RequestClient.request(
        method, requestURL, headers, requestBody,
        onRequestSent: onRequestSent);
    Response response = Response(httpResponse.statusCode,
        body: httpResponse.body, headers: httpResponse.headers);
    return response;
  }

  static Future<Response> requestSSE(String method, String requestURL,
      Map<String, String> headers, String? requestBody,
      {Future<void> Function()? onRequestSent}) async {
    http.StreamedResponse httpStreamedResponse = await RequestClient.requestSSE(
        method, requestURL, headers, requestBody,
        onRequestSent: onRequestSent);
    if (httpStreamedResponse.statusCode != 200) {
      final String body =
          await utf8.decoder.bind(httpStreamedResponse.stream).join();
      logger.log(LogModule.sse, "Request handle",
          detail:
              "statusCode: ${httpStreamedResponse.statusCode}, ${httpStreamedResponse.reasonPhrase}",
          level: Level.WARNING);
      return Response(
        httpStreamedResponse.statusCode,
        body: body,
        headers: httpStreamedResponse.headers,
      );
    }
    final Map<String, String> responseHeaders =
        Map<String, String>.from(httpStreamedResponse.headers);
    responseHeaders.removeWhere((String key, String value) => const {
          'connection',
          'transfer-encoding',
          'content-length'
        }.contains(key.toLowerCase()));
    responseHeaders.putIfAbsent('content-type', () => 'text/event-stream');
    responseHeaders.putIfAbsent('cache-control', () => 'no-cache');
    responseHeaders['connection'] = 'keep-alive';

    return Response(
      httpStreamedResponse.statusCode,
      body: logSseStream(httpStreamedResponse.stream),
      headers: responseHeaders,
    );
  }

  static Stream<List<int>> logSseStream(Stream<List<int>> stream) {
    return stream.map((List<int> event) {
      logger.log(LogModule.sse, "Request handle",
          detail: "received ${event.length} bytes", level: Level.FINEST);
      return event;
    });
  }
}
