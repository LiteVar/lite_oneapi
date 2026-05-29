import 'package:lite_oneapi/lite_oneapi.dart';

Future<void> main() async {
  final client = LiteOneApiClient(
    config: const LiteOneApiClientConfig(
      apiKey: 'sk-your-api-key',
      baseUrl: 'https://your-openai-compatible-gateway.example.com/v1',
      adapter: 'openai',
    ),
  );

  final completion = await client.chat.create(
    model: 'deepseek-v4-pro',
    messages: [
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            'Say hello in one short sentence.',
          ),
        ],
      ),
    ],
  );

  final completionContent = completion.choices.first.message.content;
  if (completionContent != null && completionContent.isNotEmpty) {
    print(completionContent.first.text);
  }

  await for (final chunk in client.chat.createStream(
    model: 'deepseek-v4-pro',
    messages: [
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            'Count from one to three.',
          ),
        ],
      ),
    ],
    streamOptions: const {'include_usage': true},
  )) {
    if (chunk.choices.isNotEmpty) {
      final content = chunk.choices.first.delta.content;
      if (content != null && content.isNotEmpty) {
        for (final item in content) {
          if (item?.text != null) {
            print(item!.text);
          }
        }
      }
    }
  }
}
