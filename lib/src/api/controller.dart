import 'package:shelf/shelf.dart';
import '../core/gateway_service.dart';

final OneApiController oneApiController = OneApiController();
final LiteOneApiGatewayService liteOneApiGatewayService = LiteOneApiGatewayService();

class OneApiController {
  Future<Response> handle(Request request) async {
    return liteOneApiGatewayService.handleHttp(request);
  }
}
