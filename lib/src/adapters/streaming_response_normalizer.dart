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
    final StringBuffer buffer = StringBuffer();

    await for (final List<int> chunk in stream) {
      buffer.write(utf8.decode(chunk));
      String current = buffer.toString();
      int delimiterIndex = current.indexOf('\n\n');

      while (delimiterIndex != -1) {
        final String frame = current.substring(0, delimiterIndex);
        current = current.substring(delimiterIndex + 2);
        yield utf8.encode(_normalizeFrame(frame));
        delimiterIndex = current.indexOf('\n\n');
      }

      buffer
        ..clear()
        ..write(current);
    }

    final String remaining = buffer.toString().trim();
    if (remaining.isNotEmpty) {
      yield utf8.encode(_normalizeFrame(remaining));
    }
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
