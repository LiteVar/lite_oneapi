import 'dart:io';
import 'package:lite_oneapi/lite_oneapi.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

Future<void> main() async {

  apiRoutes();

  Handler handler = const Pipeline()
    .addMiddleware(checkAuthorization())
    .addMiddleware(logRequest())
    .addHandler(router);

  HttpServer server = await serve(handler, config.server.ip, config.server.port);
  logger.log(LogModule.api, "Start Server", detail: "http://${server.address.host}:${server.port}");
}