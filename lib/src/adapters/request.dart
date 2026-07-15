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
      String message =
          "Failed to connect to SSE stream: ${httpStreamedResponse.reasonPhrase}";
      logger.log(LogModule.sse, "Request handle",
          detail: "statusCode: ${httpStreamedResponse.statusCode}, $message",
          level: Level.WARNING);
      return Response(httpStreamedResponse.statusCode, body: message);
    }
    return Response.ok(
      logSseStream(httpStreamedResponse.stream),
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      },
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
