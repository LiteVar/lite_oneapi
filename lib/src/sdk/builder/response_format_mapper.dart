// ignore_for_file: implementation_imports

import 'package:dart_openai_sdk/src/core/utils/extensions.dart';
import 'package:ovo/ovo.dart' as ovo;

class LiteOneApiResponseFormatMapper {
  const LiteOneApiResponseFormatMapper._();

  static Object? map(Object? responseFormat) {
    if (responseFormat == null) {
      return null;
    }
    if (responseFormat is ovo.Object) {
      return responseFormat.formatJsonData();
    }
    return responseFormat;
  }
}
