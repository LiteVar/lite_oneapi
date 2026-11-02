import 'package:dart_openai_sdk/dart_openai_sdk.dart' show OpenAiResponse;

import '../../core/gateway_service.dart';
import '../config/client_config.dart';
import '../protocol_transport.dart';
import '../streaming/sse_event.dart';
import '../streaming/sse_event_mapper.dart';

/// OpenAI Responses client routed through Lite OneAPI.
///
/// Requests use the native Responses JSON schema. Unknown provider fields are
/// preserved in the request map.
class LiteOneApiResponses {
  final LiteOneApiClientConfig config;
  final LiteOneApiProtocolTransport _transport;

  LiteOneApiResponses({
    required this.config,
    required LiteOneApiGatewayService gatewayService,
  }) : _transport = LiteOneApiProtocolTransport(
         config: config,
         gatewayService: gatewayService,
       );

  Future<OpenAiResponse> create({required Map<String, dynamic> request}) async {
    final Map<String, dynamic> response = await createRaw(request: request);
    return OpenAiResponse.fromMap(response);
  }

  /// Returns the raw Responses object when provider-specific fields are needed.
  Future<Map<String, dynamic>> createRaw({
    required Map<String, dynamic> request,
  }) async {
    final response = await _transport.send(
      requestPath: '/v1/responses',
      request: request,
      headers: _buildHeaders(),
      stream: false,
    );
    return LiteOneApiProtocolTransport.readJsonResponse(
      response,
      protocol: 'Responses',
    );
  }

  /// Streams native Responses SSE events without converting their event names.
  Stream<LiteOneApiSseEvent> createStream({
    required Map<String, dynamic> request,
  }) async* {
    final response = await _transport.send(
      requestPath: '/v1/responses',
      request: request,
      headers: _buildHeaders(accept: 'text/event-stream'),
      stream: true,
    );
    await LiteOneApiProtocolTransport.ensureStreamResponse(response);
    yield* LiteOneApiSseEventMapper.fromByteStream(response.read());
  }

  Map<String, String> _buildHeaders({String accept = 'application/json'}) {
    final Map<String, String> headers = <String, String>{...config.headers};
    if (config.apiKey != null && config.apiKey!.isNotEmpty) {
      headers.putIfAbsent('Authorization', () => 'Bearer ${config.apiKey!}');
    }
    headers.putIfAbsent('Content-Type', () => 'application/json');
    headers.putIfAbsent('Accept', () => accept);
    return headers;
  }
}
