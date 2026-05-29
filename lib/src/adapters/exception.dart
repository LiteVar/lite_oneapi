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

@JsonSerializable(createFactory: false)
class UnsupportedRequestException implements Exception {
  int code = 400;
  late String message;

  UnsupportedRequestException(this.message);

  Map<String, dynamic> toJson() => _$UnsupportedRequestExceptionToJson(this);
}
