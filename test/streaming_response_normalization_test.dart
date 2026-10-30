import 'dart:convert';

import 'package:lite_oneapi/src/adapters/chat_completions/openai/handler.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('streaming response normalization', () {
    test('continuation chunk with empty string id and name is normalized',
        () async {
      final List<Map<String, dynamic>> chunks = await _normalize([
        _toolChunk(
          id: 'call_1',
          name: 'weather',
          arguments: '{"city"',
        ),
        _toolChunk(
          id: '',
          name: '',
          arguments: ':"Paris"}',
        ),
      ]);

      expect(chunks, hasLength(2));
      expect(chunks[0]['choices'][0]['delta']['tool_calls'][0]['id'], 'call_1');
      expect(
        chunks[0]['choices'][0]['delta']['tool_calls'][0]['function']['name'],
        'weather',
      );
      expect(
        (chunks[1]['choices'][0]['delta']['tool_calls'][0]
                as Map<String, dynamic>)
            .containsKey('id'),
        isFalse,
      );
      expect(
        ((chunks[1]['choices'][0]['delta']['tool_calls'][0]['function'])
                as Map<String, dynamic>)
            .containsKey('name'),
        isFalse,
      );
      expect(
        chunks[1]['choices'][0]['delta']['tool_calls'][0]['function']
            ['arguments'],
        ':"Paris"}',
      );
    });

    test('continuation chunk with null id and name is preserved', () async {
      final List<Map<String, dynamic>> chunks = await _normalize([
        _toolChunk(
          id: 'call_1',
          name: 'weather',
          arguments: '{"city"',
        ),
        _toolChunk(
          id: null,
          name: null,
          arguments: ':"Paris"}',
        ),
      ]);

      expect(chunks, hasLength(2));
      expect(chunks[1]['choices'][0]['delta']['tool_calls'][0]['id'], isNull);
      expect(
        chunks[1]['choices'][0]['delta']['tool_calls'][0]['function']['name'],
        isNull,
      );
      expect(
        chunks[1]['choices'][0]['delta']['tool_calls'][0]['function']
            ['arguments'],
        ':"Paris"}',
      );
    });

    test('multiple tool calls remain isolated across chunks', () async {
      final List<Map<String, dynamic>> chunks = await _normalize([
        _toolChunk(
          index: 0,
          id: 'call_1',
          name: 'first_tool',
          arguments: '{"a"',
        ),
        _toolChunk(
          index: 0,
          id: '',
          name: '',
          arguments: ':1}',
        ),
        _toolChunk(
          index: 1,
          id: 'call_2',
          name: 'second_tool',
          arguments: '{"b"',
        ),
        _toolChunk(
          index: 1,
          id: '',
          name: '',
          arguments: ':2}',
        ),
      ]);

      expect(chunks, hasLength(4));
      expect(chunks[0]['choices'][0]['delta']['tool_calls'][0]['id'], 'call_1');
      expect(chunks[2]['choices'][0]['delta']['tool_calls'][0]['id'], 'call_2');
      expect(
        chunks[2]['choices'][0]['delta']['tool_calls'][0]['function']['name'],
        'second_tool',
      );
      expect(
        (chunks[3]['choices'][0]['delta']['tool_calls'][0]
                as Map<String, dynamic>)
            .containsKey('id'),
        isFalse,
      );
      expect(
        chunks[3]['choices'][0]['delta']['tool_calls'][0]['function']
            ['arguments'],
        ':2}',
      );
    });

    test('plain text streaming is unchanged', () async {
      final List<Map<String, dynamic>> chunks = await _normalize([
        <String, dynamic>{
          'id': 'chatcmpl-text',
          'object': 'chat.completion.chunk',
          'created': 1710000000,
          'model': 'gpt-4o-mini',
          'system_fingerprint': 'fp_text',
          'choices': [
            {
              'index': 0,
              'delta': {
                'role': 'assistant',
                'content': 'Hello',
              },
            },
          ],
        },
      ]);

      expect(chunks.single['choices'][0]['delta']['content'], 'Hello');
      expect(
        (chunks.single['choices'][0]['delta'] as Map<String, dynamic>)
            .containsKey('tool_calls'),
        isFalse,
      );
    });

    test('already compliant provider chunks are unchanged', () async {
      final Map<String, dynamic> compliantChunk = _toolChunk(
        id: 'call_1',
        name: 'weather',
        arguments: '{"city"',
      );

      final List<Map<String, dynamic>> chunks =
          await _normalize([compliantChunk]);
      expect(chunks.single, compliantChunk);
    });

    test(
        'preserves split UTF-8 and SSE delimiters while normalizing tool calls',
        () async {
      final Map<String, dynamic> contentChunk = <String, dynamic>{
        'id': 'chatcmpl-utf8',
        'object': 'chat.completion.chunk',
        'created': 1710000002,
        'model': 'gpt-4o-mini',
        'system_fingerprint': 'fp_utf8',
        'choices': <Map<String, dynamic>>[
          <String, dynamic>{
            'index': 0,
            'delta': <String, dynamic>{
              'role': 'assistant',
              'content': '中文回答',
            },
          },
        ],
      };
      final String firstFrame = 'data: ${jsonEncode(contentChunk)}\n\n';
      final String sse = <String>[
        firstFrame,
        'data: ${jsonEncode(_toolChunk(
          id: 'call_1',
          name: 'weather',
          arguments: '{"city"',
        ))}\n\n',
        'data: ${jsonEncode(_toolChunk(
          id: '',
          name: '',
          arguments: ':"北京"}',
        ))}\n\n',
        'data: [DONE]',
      ].join();
      final List<int> bytes = utf8.encode(sse);
      final int contentStart = _indexOfBytes(bytes, utf8.encode('中文回答'));
      final List<List<int>> byteChunks = _splitBytes(bytes, <int>[
        contentStart + utf8.encode('中').length + 2,
        utf8.encode(firstFrame).length - 1,
      ]);

      final OpenAIResponseHandler handler = OpenAIResponseHandler();
      final Response response = handler.handleStream(
        Response.ok(
          Stream<List<int>>.fromIterable(byteChunks),
          headers: {'content-type': 'text/event-stream'},
        ),
      );
      final String normalized = await utf8.decoder.bind(response.read()).join();
      final List<Map<String, dynamic>> chunks = normalized
          .split('\n\n')
          .where((String frame) => frame.startsWith('data: {'))
          .map(
            (String frame) => jsonDecode(frame.substring(5).trimLeft())
                as Map<String, dynamic>,
          )
          .toList(growable: false);

      expect(normalized, isNot(contains('\uFFFD')));
      expect(normalized, contains('data: [DONE]\n\n'));
      expect(chunks, hasLength(3));
      expect(chunks[0]['choices'][0]['delta']['content'], '中文回答');
      expect(chunks[1]['choices'][0]['delta']['tool_calls'][0]['id'], 'call_1');
      expect(
        (chunks[2]['choices'][0]['delta']['tool_calls'][0]
                as Map<String, dynamic>)
            .containsKey('id'),
        isFalse,
      );
      expect(
        (chunks[2]['choices'][0]['delta']['tool_calls'][0]['function']
                as Map<String, dynamic>)
            .containsKey('name'),
        isFalse,
      );
      expect(
        chunks[2]['choices'][0]['delta']['tool_calls'][0]['function']
            ['arguments'],
        ':"北京"}',
      );
    });
  });
}

Future<List<Map<String, dynamic>>> _normalize(
    List<Map<String, dynamic>> chunks) async {
  final OpenAIResponseHandler handler = OpenAIResponseHandler();
  final Response response = handler.handleStream(
    Response.ok(
      Stream<List<int>>.fromIterable([
        for (final Map<String, dynamic> chunk in chunks)
          utf8.encode('data: ${jsonEncode(chunk)}\n\n'),
        utf8.encode('data: [DONE]\n\n'),
      ]),
      headers: {'content-type': 'text/event-stream'},
    ),
  );

  final String raw = await utf8.decoder.bind(response.read()).join();
  return raw
      .split('\n\n')
      .where((String frame) => frame.startsWith('data: {'))
      .map((String frame) =>
          jsonDecode(frame.substring(5).trimLeft()) as Map<String, dynamic>)
      .toList(growable: false);
}

Map<String, dynamic> _toolChunk({
  int index = 0,
  String? id,
  String? name,
  required String arguments,
}) {
  return <String, dynamic>{
    'id': 'chatcmpl-tools',
    'object': 'chat.completion.chunk',
    'created': 1710000000,
    'model': 'gpt-4o-mini',
    'system_fingerprint': 'fp_tools',
    'choices': [
      {
        'index': 0,
        'delta': {
          'tool_calls': [
            {
              'index': index,
              'type': 'function',
              'id': id,
              'function': {
                'name': name,
                'arguments': arguments,
              },
            },
          ],
        },
      },
    ],
  };
}

int _indexOfBytes(List<int> bytes, List<int> pattern) {
  for (int index = 0; index <= bytes.length - pattern.length; index++) {
    bool matches = true;
    for (int patternIndex = 0; patternIndex < pattern.length; patternIndex++) {
      if (bytes[index + patternIndex] != pattern[patternIndex]) {
        matches = false;
        break;
      }
    }
    if (matches) {
      return index;
    }
  }
  throw StateError('Byte pattern not found.');
}

List<List<int>> _splitBytes(List<int> bytes, List<int> offsets) {
  final List<List<int>> chunks = <List<int>>[];
  int start = 0;
  for (final int offset in offsets) {
    chunks.add(bytes.sublist(start, offset));
    start = offset;
  }
  chunks.add(bytes.sublist(start));
  return chunks;
}
