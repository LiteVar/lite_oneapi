import 'dart:convert';

import 'sse_event.dart';

class LiteOneApiSseEventMapper {
  const LiteOneApiSseEventMapper._();

  static Stream<LiteOneApiSseEvent> fromByteStream(
    Stream<List<int>> byteStream,
  ) async* {
    String pendingLine = '';
    String? eventName;
    String? id;
    final List<String> dataLines = <String>[];

    Stream<LiteOneApiSseEvent> dispatchFrame() async* {
      if (dataLines.isNotEmpty) {
        final String rawData = dataLines.join('\n');
        if (rawData != '[DONE]') {
          final dynamic decoded = jsonDecode(rawData);
          if (decoded is! Map<String, dynamic>) {
            throw const FormatException(
              'lite_oneapi stream returned a non-object event.',
            );
          }
          yield LiteOneApiSseEvent(
            eventName: eventName ?? decoded['type'] as String?,
            id: id,
            data: decoded,
          );
        }
      }
      eventName = null;
      id = null;
      dataLines.clear();
    }

    void acceptLine(String line) {
      if (line.isEmpty || line.startsWith(':')) return;
      final int colon = line.indexOf(':');
      final String field = colon < 0 ? line : line.substring(0, colon);
      String value = colon < 0 ? '' : line.substring(colon + 1);
      if (value.startsWith(' ')) value = value.substring(1);

      switch (field) {
        case 'event':
          eventName = value;
        case 'id':
          id = value;
        case 'data':
          dataLines.add(value);
      }
    }

    await for (final String chunk in const Utf8Decoder(
      allowMalformed: true,
    ).bind(byteStream)) {
      pendingLine += chunk;
      while (true) {
        final int lineBreak = pendingLine.indexOf('\n');
        if (lineBreak < 0) break;
        String line = pendingLine.substring(0, lineBreak);
        pendingLine = pendingLine.substring(lineBreak + 1);
        if (line.endsWith('\r')) line = line.substring(0, line.length - 1);
        if (line.isEmpty) {
          yield* dispatchFrame();
        } else {
          acceptLine(line);
        }
      }
    }

    if (pendingLine.isNotEmpty) {
      if (pendingLine.endsWith('\r')) {
        pendingLine = pendingLine.substring(0, pendingLine.length - 1);
      }
      acceptLine(pendingLine);
    }
    yield* dispatchFrame();
  }
}
