import '../core/gateway_service.dart';
import 'chat/chat.dart';
import 'config/client_config.dart';
import 'messages/lite_oneapi_messages.dart';
import 'responses/lite_oneapi_responses.dart';

class LiteOneApiClient {
  final LiteOneApiClientConfig config;
  final LiteOneApiGatewayService gatewayService;

  late final LiteOneApiChat _chat;
  late final LiteOneApiResponses _responses;
  late final LiteOneApiMessages _messages;

  LiteOneApiClient({
    LiteOneApiClientConfig config = const LiteOneApiClientConfig(),
    LiteOneApiGatewayService? gatewayService,
  }) : config = config,
       gatewayService = gatewayService ?? LiteOneApiGatewayService() {
    _chat = LiteOneApiChat(
      config: this.config,
      gatewayService: this.gatewayService,
    );
    _responses = LiteOneApiResponses(
      config: this.config,
      gatewayService: this.gatewayService,
    );
    _messages = LiteOneApiMessages(
      config: this.config,
      gatewayService: this.gatewayService,
    );
  }

  LiteOneApiChat get chat => _chat;
  LiteOneApiResponses get responses => _responses;
  LiteOneApiMessages get messages => _messages;

  LiteOneApiClient copyWith({
    LiteOneApiClientConfig? config,
    LiteOneApiGatewayService? gatewayService,
  }) {
    return LiteOneApiClient(
      config: config ?? this.config,
      gatewayService: gatewayService ?? this.gatewayService,
    );
  }
}
