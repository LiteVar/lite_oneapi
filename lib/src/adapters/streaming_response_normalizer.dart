import 'dart:convert';

class StreamingResponseNormalizer {
  const StreamingResponseNormalizer._();

  static Map<String, dynamic> normalizeChunk(Map<String, dynamic> chunk) {
    final dynamic choices = chunk['choices'];
    if (choices is! List) {
      return chunk;
    }

    for (final dynamic choice in choices) {
      if (choice is! Map<String, dynamic>) {
        continue;
      }

      final dynamic delta = choice['delta'];
      if (delta is! Map<String, dynamic>) {
        continue;
      }

      final dynamic toolCalls = delta['tool_calls'];
      if (toolCalls is! List) {
        continue;
      }

      for (final dynamic toolCall in toolCalls) {
        if (toolCall is! Map<String, dynamic>) {
          continue;
        }

        _removeEmptyStringField(toolCall, 'id');

        final dynamic function = toolCall['function'];
        if (function is Map<String, dynamic>) {
          _removeEmptyStringField(function, 'name');
        }
      }
    }

    return chunk;
  }

  static Stream<List<int>> normalizeSseStream(Stream<List<int>> stream) async* {
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
      for (final String event in decoded.replaceAll('\r\n', '\n').split('\n\n')) {
        if (event.trim().isEmpty) continue;
        yield utf8.encode(_normalizeFrame(event));
      }
    }

    if (byteBuffer.isNotEmpty) {
      final String decoded = utf8.decode(byteBuffer, allowMalformed: true).trim();
      if (decoded.isNotEmpty) {
        yield utf8.encode(_normalizeFrame(decoded));
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

  static String _normalizeFrame(String frame) {
    final String? data = _extractData(frame);
    if (data == null || data == '[DONE]') {
      return '$frame\n\n';
    }

    final dynamic decoded = jsonDecode(data);
    if (decoded is! Map<String, dynamic>) {
      return '$frame\n\n';
    }

    final Map<String, dynamic> normalized = normalizeChunk(decoded);
    return 'data: ${jsonEncode(normalized)}\n\n';
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

  static void _removeEmptyStringField(Map<String, dynamic> object, String key) {
    final dynamic value = object[key];
    if (value is String && value.isEmpty) {
      object.remove(key);
    }
  }
}
