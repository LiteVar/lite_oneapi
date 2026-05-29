import '../core/gateway_service.dart';
import 'chat/chat.dart';
import 'config/client_config.dart';

class LiteOneApiClient {
  final LiteOneApiClientConfig config;
  final LiteOneApiGatewayService gatewayService;

  late final LiteOneApiChat _chat;

  LiteOneApiClient({
    LiteOneApiClientConfig config = const LiteOneApiClientConfig(),
    LiteOneApiGatewayService? gatewayService,
  }) : config = config,
       gatewayService = gatewayService ?? LiteOneApiGatewayService() {
    _chat = LiteOneApiChat(
      config: this.config,
      gatewayService: this.gatewayService,
    );
  }

  LiteOneApiChat get chat => _chat;

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
