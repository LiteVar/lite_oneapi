import 'package:shelf_router/shelf_router.dart';

import 'controller.dart';

final Router router = Router();

void apiRoutes() {
  router.all('/<path|.*>', oneApiController.handle);
}