import 'dart:convert';

import 'package:lite_oneapi/src/adapters/minimax/adapter.dart';
import 'package:lite_oneapi/src/api/meta.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('MiniMax reasoning compatibility', () {
    test('adapter adds reasoning_split and maps reasoning_content to reasoning_details', () async {
      final MiniMaxAdapter adapter = MiniMaxAdapter();
      final Meta meta = Meta(
        model: 'MiniMax-M2.7',
        isStream: false,
        requestBody: jsonEncode({
          'model': 'MiniMax-M2.7',
          'messages': [
            {
              'role': 'assistant',
              'content': 'final answer',
              'reasoning_content': 'internal reasoning',
            },
          ],
        }),
      );

      final Request request = Request(
        'POST',
        Uri.parse('http://localhost/v1/chat/completions'),
      );

      final Map<String, dynamic> converted = await adapter.convertRequest(request, meta);

      expect(converted['reasoning_split'], true);
      expect(
        converted['messages'][0]['reasoning_details'][0]['text'],
        'internal reasoning',
      );
    });

    test('handler maps non-stream reasoning_details to reasoning_content', () async {
      final MiniMaxAdapter adapter = MiniMaxAdapter();
      final Response handled = adapter.responseHandler.handle(
        Response.ok(
          jsonEncode({
            'id': 'chatcmpl-minimax',
            'object': 'chat.completion',
            'created': 1710000000,
            'model': 'MiniMax-M2.7',
            'system_fingerprint': 'fp_minimax',
            'choices': [
              {
                'index': 0,
                'finish_reason': 'stop',
                'message': {
                  'role': 'assistant',
                  'content': 'hello',
                  'reasoning_details': [
                    {'text': 'step 1'},
                    {'text': 'step 2'},
                  ],
                },
              },
            ],
            'usage': {
              'prompt_tokens': 1,
              'completion_tokens': 2,
              'total_tokens': 3,
            },
          }),
          headers: {'content-type': 'application/json'},
        ),
      );

      final Map<String, dynamic> decoded =
          jsonDecode(await handled.readAsString()) as Map<String, dynamic>;
      final Map<String, dynamic> message =
          decoded['choices'][0]['message'] as Map<String, dynamic>;

      expect(message['content'], 'hello');
      expect(message['reasoning_content'], 'step 1step 2');
      expect(message.containsKey('reasoning_details'), isFalse);
    });

    test('handler converts cumulative stream reasoning into OpenAI deltas', () async {
      final MiniMaxAdapter adapter = MiniMaxAdapter();
      final Response handled = adapter.responseHandler.handleStream(
        Response.ok(
          Stream<List<int>>.fromIterable([
            utf8.encode(
              'data: {"id":"chatcmpl-stream","object":"chat.completion.chunk","created":1710000001,"model":"MiniMax-M2.7","system_fingerprint":"fp_minimax","choices":[{"index":0,"delta":{"role":"assistant","content":"","reasoning_details":[{"text":"Plan"}]}}]}\n\n',
            ),
            utf8.encode(
              'data: {"id":"chatcmpl-stream","object":"chat.completion.chunk","created":1710000001,"model":"MiniMax-M2.7","system_fingerprint":"fp_minimax","choices":[{"index":0,"delta":{"content":"Hello","reasoning_details":[{"text":"Plan more"}]}}]}\n\n',
            ),
            utf8.encode(
              'data: {"id":"chatcmpl-stream","object":"chat.completion.chunk","created":1710000001,"model":"MiniMax-M2.7","system_fingerprint":"fp_minimax","choices":[{"index":0,"delta":{"content":"Hello world","reasoning_details":[{"text":"Plan more details"}]},"finish_reason":"stop"}]}\n\n',
            ),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          headers: {'content-type': 'text/event-stream'},
        ),
      );

      final String raw = await utf8.decoder.bind(handled.read()).join();
      final List<Map<String, dynamic>> chunks = raw
          .split('\n\n')
          .where((String frame) => frame.startsWith('data: {'))
          .map((String frame) => jsonDecode(frame.substring(5).trimLeft()) as Map<String, dynamic>)
          .toList(growable: false);

      expect(chunks, hasLength(3));
      expect(chunks[0]['choices'][0]['delta']['reasoning_content'], 'Plan');
      expect(chunks[0]['choices'][0]['delta']['content'], '');
      expect(chunks[1]['choices'][0]['delta']['reasoning_content'], ' more');
      expect(chunks[1]['choices'][0]['delta']['content'], 'Hello');
      expect(chunks[2]['choices'][0]['delta']['reasoning_content'], ' details');
      expect(chunks[2]['choices'][0]['delta']['content'], ' world');
      expect(chunks[2]['choices'][0]['finish_reason'], 'stop');
    });
  });
}
