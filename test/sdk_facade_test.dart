import 'dart:convert';

import 'package:lite_oneapi/lite_oneapi.dart';
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
    return nextResponse ?? Response.internalServerError(body: 'missing fake response');
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

      final payload = jsonDecode(fakeGateway.lastPayload!) as Map<String, dynamic>;
      expect(payload['model'], 'deepseek-v4-pro');
      expect(payload['base_url'], 'https://proxy.example.com/v1');
      expect(payload['adapter'], 'openai');
      expect(payload['reasoning_effort'], 'high');
      expect(payload['messages'][0]['role'], 'user');
      expect(payload['messages'][0]['content'][0]['text'], 'hello');
    });

    test('chat.create preserves reasoning_content in request and response', () async {
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
              OpenAIChatCompletionChoiceMessageContentItemModel.text('final answer'),
            ],
            reasoningContent: 'hidden chain',
          ),
        ],
      );

      final Map<String, dynamic> payload = jsonDecode(fakeGateway.lastPayload!) as Map<String, dynamic>;
      expect(payload['messages'][0]['reasoning_content'], 'hidden chain');
      expect(result.choices.first.message.reasoningContent, 'hidden chain');
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

      final payload = jsonDecode(fakeGateway.lastPayload!) as Map<String, dynamic>;
      expect(payload['stream'], true);
      expect(payload['stream_options']['include_usage'], true);
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
  });
}
