// ignore_for_file: implementation_imports

import 'dart:convert';

import 'package:dart_openai_sdk/dart_openai_sdk.dart'
    show OpenAIStreamChatCompletionModel, RequestFailedException;

import 'error_mapper.dart';

class LiteOneApiChatStreamResponseMapper {
  const LiteOneApiChatStreamResponseMapper._();

  static Stream<OpenAIStreamChatCompletionModel> fromSseByteStream(
    Stream<List<int>> stream, {
    int statusCode = 200,
  }) async* {
    final StringBuffer buffer = StringBuffer();

    await for (final List<int> chunk in stream) {
      buffer.write(utf8.decode(chunk));
      String current = buffer.toString();
      int delimiterIndex = current.indexOf('\n\n');

      while (delimiterIndex != -1) {
        final String frame = current.substring(0, delimiterIndex);
        current = current.substring(delimiterIndex + 2);

        final String? data = _extractData(frame);
        if (data != null && data != '[DONE]') {
          final dynamic decoded = jsonDecode(data);
          if (decoded is! Map<String, dynamic>) {
            throw StateError('lite_oneapi stream returned a non-object chunk.');
          }
          try {
            LiteOneApiErrorMapper.throwIfBusinessErrorMap(decoded, statusCode: statusCode);
          } on RequestFailedException {
            rethrow;
          }
          yield OpenAIStreamChatCompletionModel.fromMap(decoded);
        }

        delimiterIndex = current.indexOf('\n\n');
      }

      buffer
        ..clear()
        ..write(current);
    }

    final String remaining = buffer.toString().trim();
    if (remaining.isNotEmpty) {
      final String? data = _extractData(remaining);
      if (data != null && data != '[DONE]') {
        final dynamic decoded = jsonDecode(data);
        if (decoded is! Map<String, dynamic>) {
          throw StateError('lite_oneapi stream returned a non-object chunk.');
        }
        LiteOneApiErrorMapper.throwIfBusinessErrorMap(decoded, statusCode: statusCode);
        yield OpenAIStreamChatCompletionModel.fromMap(decoded);
      }
    }
  }

  static String? _extractData(String frame) {
    final List<String> dataLines = frame
        .split('\n')
        .where((String line) => line.startsWith('data:'))
        .map((String line) => line.substring(5).trimLeft())
        .toList(growable: false);

    if (dataLines.isEmpty) {
      return null;
    }

    return dataLines.join('\n');
  }
}
