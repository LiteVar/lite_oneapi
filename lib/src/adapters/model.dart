import 'package:lite_oneapi/src/model.dart';

class ModelInfo {
  String name;
  String adapter;
  String baseUrl;

  ModelInfo({required this.name, required this.adapter, required this.baseUrl});
}

class IndexApiKey {
  int id;
  ApiKeyType type;
  String? apiKey;

  IndexApiKey({required this.id, required this.type, required this.apiKey});
}