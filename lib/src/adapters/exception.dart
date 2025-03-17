import 'package:json_annotation/json_annotation.dart';

part 'exception.g.dart';

@JsonSerializable(createFactory: false)
class AdapterNotFoundException implements Exception {
  int code = 404;
  late String message;

  AdapterNotFoundException(String model) {
    this.message = "Model `$model` adapter not found";
  }

  Map<String, dynamic> toJson() => _$AdapterNotFoundExceptionToJson(this);
}