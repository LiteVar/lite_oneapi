import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import '../config.dart';
import '../utils/logger.dart';

Middleware checkAuthorization() {
  List<String> apiKeys = env.apiKeys;
  return (Handler innerHandler) {
    return (Request request) async {
      final authorizationHeader = request.headers['Authorization'];
      final tokenPrefix = "Bearer ";

      if(apiKeys.isNotEmpty) {
        if (authorizationHeader != null) {
          for(String apiKey in apiKeys) {
            if(authorizationHeader == tokenPrefix + apiKey) {
              return innerHandler(request);
            }
          }
          return Response.unauthorized('Invalid or missing authorization token');
        } else {
          return Response.unauthorized('Invalid or missing authorization token');
        }
      }
      return innerHandler(request);
    };
  };
}

Middleware logRequest() {
  return (Handler innerHandler) {
    return (Request request) async {
      String method = request.method;
      String uri = request.requestedUri.toString();
      String body = await request.readAsString();
      logger.log(LogModule.api, "logRequest", detail: "[$method] $uri $body", level: Level.FINE);
      Request newRequest = request.change(body: body);
      return innerHandler(newRequest);
    };
  };
}
