import 'dart:convert';

import 'package:lite_oneapi/lite_oneapi.dart';
import 'package:ovo/ovo.dart' as ovo;
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

class FakeGatewayService extends LiteOneApiGatewayService {
  String? lastPayload;
  String? lastPath;
  Map<String, String>? lastHeaders;
  Response? nextResponse;

  @override
  Future<Response> handleJsonRequest({
    required String payload,
    required String requestPath,
    required Map<String, String> requestHeaders,
    String method = "POST",
  }) async {
    lastPayload = payload;
    lastPath = requestPath;
    lastHeaders = requestHeaders;
    return nextResponse ??
        Response.internalServerError(body: 'missing fake response');
  }
}

void main() {
  group('LiteOneApiClient SDK facade', () {
    test('chat.create maps request and parses OpenAI-style response', () async {
      final fakeGateway = FakeGatewayService()
        ..nextResponse = Response.ok(
          jsonEncode({
            'id': 'chatcmpl-test',
            'created': 1710000000,
            'choices': [
              {
                'index': 0,
                'finish_reason': 'stop',
                'message': {
                  'role': 'assistant',
                  'content': 'hello from lite_oneapi',
                },
              },
            ],
            'usage': {
              'prompt_tokens': 3,
              'completion_tokens': 4,
              'total_tokens': 7,
            },
            'system_fingerprint': 'fp_test',
          }),
          headers: {'content-type': 'application/json'},
        );

      final client = LiteOneApiClient(
        config: const LiteOneApiClientConfig(
          apiKey: 'sk-test',
          baseUrl: 'https://proxy.example.com/v1',
          adapter: 'openai',
        ),
        gatewayService: fakeGateway,
      );

      final result = await client.chat.create(
        model: 'deepseek-v4-pro',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text('hello'),
            ],
          ),
        ],
        reasoningEffort: 'high',
      );

      expect(result.id, 'chatcmpl-test');
      final resultContent = result.choices.first.message.content;
      expect(resultContent, isNotNull);
      expect(resultContent!.first.text, 'hello from lite_oneapi');
      expect(fakeGateway.lastPath, '/v1/chat/completions');
      expect(fakeGateway.lastHeaders?['Authorization'], 'Bearer sk-test');

      final payload =
          jsonDecode(fakeGateway.lastPayload!) as Map<String, dynamic>;
      expect(payload['model'], 'deepseek-v4-pro');
      expect(payload['base_url'], 'https://proxy.example.com/v1');
      expect(payload['adapter'], 'openai');
      expect(payload['reasoning_effort'], 'high');
      expect(payload['messages'][0]['role'], 'user');
      expect(payload['messages'][0]['content'][0]['text'], 'hello');
    });

    test('chat.create preserves reasoning_content in request and response',
        () async {
      final fakeGateway = FakeGatewayService()
        ..nextResponse = Response.ok(
          jsonEncode({
            'id': 'chatcmpl-reasoning',
            'created': 1710000002,
            'choices': [
              {
                'index': 0,
                'finish_reason': 'stop',
                'message': {
                  'role': 'assistant',
                  'content': 'final answer',
                  'reasoning_content': 'hidden chain',
                },
              },
            ],
            'usage': {
              'prompt_tokens': 5,
              'completion_tokens': 6,
              'total_tokens': 11,
            },
            'system_fingerprint': 'fp_reasoning',
          }),
          headers: {'content-type': 'application/json'},
        );

      final client = LiteOneApiClient(
        config: const LiteOneApiClientConfig(apiKey: 'sk-test'),
        gatewayService: fakeGateway,
      );

      final result = await client.chat.create(
        model: 'glm-5.1',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.assistant,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  'final answer'),
            ],
            reasoningContent: 'hidden chain',
          ),
        ],
      );

      final Map<String, dynamic> payload =
          jsonDecode(fakeGateway.lastPayload!) as Map<String, dynamic>;
      expect(payload['messages'][0]['reasoning_content'], 'hidden chain');
      expect(result.choices.first.message.reasoningContent, 'hidden chain');
    });

    test('chat.create maps ovo response format to json_schema payload',
        () async {
      final fakeGateway = FakeGatewayService()
        ..nextResponse = Response.ok(
          jsonEncode({
            'id': 'chatcmpl-schema',
            'created': 1710000004,
            'choices': [
              {
                'index': 0,
                'finish_reason': 'stop',
                'message': {
                  'role': 'assistant',
                  'content': 'schema output',
                },
              },
            ],
            'usage': {
              'prompt_tokens': 1,
              'completion_tokens': 1,
              'total_tokens': 2,
            },
            'system_fingerprint': 'fp_schema',
          }),
          headers: {'content-type': 'application/json'},
        );

      final client = LiteOneApiClient(
        config: const LiteOneApiClientConfig(apiKey: 'sk-test'),
        gatewayService: fakeGateway,
      );

      await client.chat.create(
        model: 'gpt-4o-mini',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text('hello'),
            ],
          ),
        ],
        responseFormat: ovo.Object({
          'status': ovo.String(),
        }),
      );

      final Map<String, dynamic> payload =
          jsonDecode(fakeGateway.lastPayload!) as Map<String, dynamic>;
      expect(payload['response_format']['type'], 'json_schema');
      expect(
          payload['response_format']['json_schema']['schema']['properties']
              ['status']['type'],
          'string');
    });

    test(
        'chat.create throws RequestFailedException for 200 business error body',
        () async {
      final fakeGateway = FakeGatewayService()
        ..nextResponse = Response.ok(
          jsonEncode({
            'code': 30015,
            'message': 'provider business error',
          }),
          headers: {'content-type': 'application/json'},
        );

      final client = LiteOneApiClient(
        config: const LiteOneApiClientConfig(apiKey: 'sk-test'),
        gatewayService: fakeGateway,
      );

      expect(
        () => client.chat.create(
          model: 'gpt-4o-mini',
          messages: [
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text('hello'),
              ],
            ),
          ],
        ),
        throwsA(
          isA<RequestFailedException>().having(
            (RequestFailedException e) => e.message,
            'message',
            'provider business error',
          ),
        ),
      );
    });

    test('chat.createStream parses SSE chunks and usage chunk', () async {
      final fakeGateway = FakeGatewayService()
        ..nextResponse = Response.ok(
          Stream<List<int>>.fromIterable([
            utf8.encode(
              'data: {"id":"chatcmpl-stream","created":1710000001,"choices":[{"index":0,"delta":{"role":"assistant","content":"Hel"}}],"system_fingerprint":"fp_stream"}\n\n',
            ),
            utf8.encode(
              'data: {"id":"chatcmpl-stream","created":1710000001,"choices":[{"index":0,"delta":{"content":"lo"},"finish_reason":"stop"}],"system_fingerprint":"fp_stream"}\n\n',
            ),
            utf8.encode(
              'data: {"id":"chatcmpl-stream","created":1710000001,"choices":[],"usage":{"prompt_tokens":1,"completion_tokens":2,"total_tokens":3},"system_fingerprint":"fp_stream"}\n\n',
            ),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          headers: {'content-type': 'text/event-stream'},
        );

      final client = LiteOneApiClient(
        config: const LiteOneApiClientConfig(
          apiKey: 'sk-test',
        ),
        gatewayService: fakeGateway,
      );

      final chunks = await client.chat.createStream(
        model: 'qwen-plus',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text('hello'),
            ],
          ),
        ],
        streamOptions: const {'include_usage': true},
      ).toList();

      expect(chunks, hasLength(3));
      final firstChunkContent = chunks[0].choices.first.delta.content;
      final secondChunkContent = chunks[1].choices.first.delta.content;
      expect(firstChunkContent, isNotNull);
      expect(secondChunkContent, isNotNull);
      expect(firstChunkContent!.first?.text, 'Hel');
      expect(secondChunkContent!.first?.text, 'lo');
      expect(chunks[1].choices.first.finishReason, 'stop');
      expect(chunks[2].usage?.totalTokens, 3);

      final payload =
          jsonDecode(fakeGateway.lastPayload!) as Map<String, dynamic>;
      expect(payload['stream'], true);
      expect(payload['stream_options']['include_usage'], true);
    });

    test('chat.createStream preserves UTF-8 split inside Chinese characters',
        () async {
      const String content = '中文回答';
      final String sse = <String>[
        'data: ${jsonEncode(<String, dynamic>{
              'id': 'chatcmpl-utf8',
              'created': 1710000005,
              'choices': <Map<String, dynamic>>[
                <String, dynamic>{
                  'index': 0,
                  'delta': <String, dynamic>{
                    'role': 'assistant',
                    'content': content,
                  },
                },
              ],
              'system_fingerprint': 'fp_utf8',
            })}\n\n',
        'data: ${jsonEncode(<String, dynamic>{
              'id': 'chatcmpl-utf8',
              'created': 1710000005,
              'choices': <Map<String, dynamic>>[
                <String, dynamic>{
                  'index': 0,
                  'delta': <String, dynamic>{},
                  'finish_reason': 'stop',
                },
              ],
              'system_fingerprint': 'fp_utf8',
            })}\n\n',
        'data: ${jsonEncode(<String, dynamic>{
              'id': 'chatcmpl-utf8',
              'created': 1710000005,
              'choices': <dynamic>[],
              'usage': <String, dynamic>{
                'prompt_tokens': 2,
                'completion_tokens': 4,
                'total_tokens': 6,
              },
              'system_fingerprint': 'fp_utf8',
            })}\n\n',
        'data: [DONE]\n\n',
      ].join();
      final List<int> bytes = utf8.encode(sse);
      final int middleStart = _indexOfBytes(bytes, utf8.encode('中'));
      final int textStart = _indexOfBytes(bytes, utf8.encode('文'));
      final List<List<int>> byteChunks = _splitBytes(bytes, <int>[
        middleStart + 1,
        textStart + 2,
      ]);

      final fakeGateway = FakeGatewayService()
        ..nextResponse = Response.ok(
          Stream<List<int>>.fromIterable(byteChunks),
          headers: {'content-type': 'text/event-stream'},
        );
      final client = LiteOneApiClient(
        config: const LiteOneApiClientConfig(apiKey: 'sk-test'),
        gatewayService: fakeGateway,
      );

      final chunks = await client.chat.createStream(
        model: 'qwen-plus',
        messages: <OpenAIChatCompletionChoiceMessageModel>[
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: <OpenAIChatCompletionChoiceMessageContentItemModel>[
              OpenAIChatCompletionChoiceMessageContentItemModel.text('hello'),
            ],
          ),
        ],
        streamOptions: const {'include_usage': true},
      ).toList();

      expect(chunks, hasLength(3));
      final String? decodedContent =
          chunks[0].choices.first.delta.content?.first?.text;
      expect(decodedContent, content);
      expect(decodedContent, isNot(contains('\uFFFD')));
      expect(chunks[1].choices.first.finishReason, 'stop');
      expect(chunks[2].usage?.totalTokens, 6);
    });

    test('chat.createStream parses reasoning_content deltas', () async {
      final fakeGateway = FakeGatewayService()
        ..nextResponse = Response.ok(
          Stream<List<int>>.fromIterable([
            utf8.encode(
              'data: {"id":"chatcmpl-stream","created":1710000003,"choices":[{"index":0,"delta":{"role":"assistant","reasoning_content":"think-1","content":"Hi"}}],"system_fingerprint":"fp_stream"}\n\n',
            ),
            utf8.encode(
              'data: {"id":"chatcmpl-stream","created":1710000003,"choices":[{"index":0,"delta":{"reasoning_content":"think-2","content":" there"},"finish_reason":"stop"}],"system_fingerprint":"fp_stream"}\n\n',
            ),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          headers: {'content-type': 'text/event-stream'},
        );

      final client = LiteOneApiClient(
        config: const LiteOneApiClientConfig(apiKey: 'sk-test'),
        gatewayService: fakeGateway,
      );

      final chunks = await client.chat.createStream(
        model: 'kimi-k2.5',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text('hello'),
            ],
          ),
        ],
      ).toList();

      expect(chunks, hasLength(2));
      expect(chunks[0].choices.first.delta.reasoningContent, 'think-1');
      expect(chunks[1].choices.first.delta.reasoningContent, 'think-2');
    });

    test(
        'chat.createStream throws RequestFailedException for business error chunk',
        () async {
      final fakeGateway = FakeGatewayService()
        ..nextResponse = Response.ok(
          Stream<List<int>>.fromIterable([
            utf8.encode(
                'data: {"code":30015,"message":"stream business error"}\n\n'),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          headers: {'content-type': 'text/event-stream'},
        );

      final client = LiteOneApiClient(
        config: const LiteOneApiClientConfig(apiKey: 'sk-test'),
        gatewayService: fakeGateway,
      );

      expect(
        () => client.chat.createStream(
          model: 'gpt-4o-mini',
          messages: [
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text('hello'),
              ],
            ),
          ],
        ).toList(),
        throwsA(
          isA<RequestFailedException>().having(
            (RequestFailedException e) => e.message,
            'message',
            'stream business error',
          ),
        ),
      );
    });
  });
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
