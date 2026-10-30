// ignore_for_file: implementation_imports

import 'dart:convert';

import 'package:dart_openai_sdk/dart_openai_sdk.dart'
    show OpenAIChatCompletionModel;

import 'error_mapper.dart';
import 'encrypted_content.dart';

class LiteOneApiChatResponseMapper {
  const LiteOneApiChatResponseMapper._();

  static OpenAIChatCompletionModel fromJsonString(String rawJson) {
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw StateError(
          'lite_oneapi returned a non-object chat completion response.');
    }
    LiteOneApiErrorMapper.throwIfBusinessErrorMap(decoded, statusCode: 200);
    final OpenAIChatCompletionModel completion =
        OpenAIChatCompletionModel.fromMap(decoded);
    LiteOneApiEncryptedContent.attachCompletion(decoded, completion);
    return completion;
  }
}
