import '../../core/gateway_service.dart';
import '../config/client_config.dart';
import '../protocol_transport.dart';
import '../streaming/sse_event.dart';
import '../streaming/sse_event_mapper.dart';

/// Anthropic Messages client routed through Lite OneAPI.
///
/// Requests and responses use Anthropic's native Messages JSON schema. The
/// request map is kept independent from Chat Completions and Responses.
class LiteOneApiMessages {
  final LiteOneApiClientConfig config;
  final LiteOneApiProtocolTransport _transport;

  LiteOneApiMessages({
    required this.config,
    required LiteOneApiGatewayService gatewayService,
  }) : _transport = LiteOneApiProtocolTransport(
         config: config,
         gatewayService: gatewayService,
       );

  Future<Map<String, dynamic>> create({
    required Map<String, dynamic> request,
  }) async {
    final response = await _transport.send(
      requestPath: '/v1/messages',
      request: request,
      headers: _buildHeaders(),
      stream: false,
    );
    return LiteOneApiProtocolTransport.readJsonResponse(
      response,
      protocol: 'Messages',
    );
  }

  /// Streams Anthropic Messages events and preserves each SSE event name.
  Stream<LiteOneApiSseEvent> createStream({
    required Map<String, dynamic> request,
  }) async* {
    final response = await _transport.send(
      requestPath: '/v1/messages',
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
      headers.putIfAbsent('x-api-key', () => config.apiKey!);
    }
    headers.putIfAbsent('anthropic-version', () => '2023-06-01');
    headers.putIfAbsent('Content-Type', () => 'application/json');
    headers.putIfAbsent('Accept', () => accept);
    return headers;
  }
}
