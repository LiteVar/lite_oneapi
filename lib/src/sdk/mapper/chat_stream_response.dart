// ignore_for_file: implementation_imports

import 'dart:convert';

import 'package:dart_openai_sdk/dart_openai_sdk.dart'
    show OpenAIStreamChatCompletionModel, RequestFailedException;

import 'error_mapper.dart';
import 'encrypted_content.dart';

class LiteOneApiChatStreamResponseMapper {
  const LiteOneApiChatStreamResponseMapper._();

  static Stream<OpenAIStreamChatCompletionModel> fromSseByteStream(
    Stream<List<int>> stream, {
    int statusCode = 200,
  }) async* {
    final List<int> byteBuffer = <int>[];

    await for (final List<int> chunk in stream) {
      byteBuffer.addAll(chunk);
      int boundary = _lastEventBoundary(byteBuffer);
      if (boundary < 0) continue;

      final List<int> complete = byteBuffer.sublist(0, boundary);
      final List<int> remainder = byteBuffer.sublist(boundary);
      byteBuffer
        ..clear()
        ..addAll(remainder);

      final String decoded = utf8.decode(complete, allowMalformed: true);
      for (final String event
          in decoded.replaceAll('\r\n', '\n').split('\n\n')) {
        if (event.trim().isEmpty) continue;

        final String? data = _extractData(event);
        if (data != null && data != '[DONE]') {
          final dynamic decodedJson = jsonDecode(data);
          if (decodedJson is! Map<String, dynamic>) {
            throw StateError('lite_oneapi stream returned a non-object chunk.');
          }
          try {
            LiteOneApiErrorMapper.throwIfBusinessErrorMap(decodedJson,
                statusCode: statusCode);
          } on RequestFailedException {
            rethrow;
          }
          final OpenAIStreamChatCompletionModel chunk =
              OpenAIStreamChatCompletionModel.fromMap(decodedJson);
          LiteOneApiEncryptedContent.attachStreamChunk(decodedJson, chunk);
          yield chunk;
        }
      }
    }

    if (byteBuffer.isNotEmpty) {
      final String decoded =
          utf8.decode(byteBuffer, allowMalformed: true).trim();
      if (decoded.isNotEmpty) {
        final String? data = _extractData(decoded);
        if (data != null && data != '[DONE]') {
          final dynamic decodedJson = jsonDecode(data);
          if (decodedJson is! Map<String, dynamic>) {
            throw StateError('lite_oneapi stream returned a non-object chunk.');
          }
          LiteOneApiErrorMapper.throwIfBusinessErrorMap(decodedJson,
              statusCode: statusCode);
          final OpenAIStreamChatCompletionModel chunk =
              OpenAIStreamChatCompletionModel.fromMap(decodedJson);
          LiteOneApiEncryptedContent.attachStreamChunk(decodedJson, chunk);
          yield chunk;
        }
      }
    }
  }

  static int _lastEventBoundary(List<int> bytes) {
    for (int i = bytes.length - 1; i >= 1; i--) {
      if (bytes[i] != 0x0A) continue;
      if (bytes[i - 1] == 0x0A) return i + 1; // \n\n
      if (i >= 3 &&
          bytes[i - 1] == 0x0D &&
          bytes[i - 2] == 0x0A &&
          bytes[i - 3] == 0x0D) {
        return i + 1; // \r\n\r\n
      }
    }
    return -1;
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
