import 'package:lite_oneapi/lite_oneapi_client.dart';

Future<void> main() async {
  final client = LiteOneApiClient(
    config: const LiteOneApiClientConfig(
      apiKey: 'sk-your-api-key',
      adapter: 'hunyuan',
    ),
  );

  final response = await client.responses.create(
    request: {'model': 'hy3', 'input': 'Reply with OK.'},
  );
  print(response.id);

  final message = await client.messages.create(
    request: {
      'model': 'hy3',
      'max_tokens': 128,
      'messages': [
        {'role': 'user', 'content': 'Reply with OK.'},
      ],
    },
  );
  print(message['stop_reason']);

  await for (final LiteOneApiSseEvent event in client.messages.createStream(
    request: {
      'model': 'hy3',
      'max_tokens': 128,
      'messages': [
        {'role': 'user', 'content': 'Reply with OK.'},
      ],
    },
  )) {
    print('${event.eventName}: ${event.data}');
  }
}
