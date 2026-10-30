import 'package:dart_openai_sdk/dart_openai_sdk.dart'
    show
        OpenAIChatCompletionChoiceMessageModel,
        OpenAIChatCompletionModel,
        OpenAIStreamChatCompletionChoiceDeltaModel,
        OpenAIStreamChatCompletionModel;

final Expando<String> _encryptedContent = Expando<String>('encrypted_content');

/// Access to Ark's opaque reasoning payload, which is outside the OpenAI SDK
/// message model but must be replayed unchanged in later turns.
class LiteOneApiEncryptedContent {
  const LiteOneApiEncryptedContent._();

  static String? read(Object message) => _encryptedContent[message];

  static void attach(Object message, String? value) {
    if (value != null) _encryptedContent[message] = value;
  }

  static Map<String, dynamic> toMessageMap(
    OpenAIChatCompletionChoiceMessageModel message,
  ) {
    final Map<String, dynamic> result = message.toMap();
    final String? encryptedContent = read(message);
    if (encryptedContent != null) {
      result['encrypted_content'] = encryptedContent;
    }
    return result;
  }

  static void attachCompletion(
    Map<String, dynamic> raw,
    OpenAIChatCompletionModel completion,
  ) {
    final dynamic rawChoices = raw['choices'];
    if (rawChoices is! List) return;

    final int choiceCount = rawChoices.length < completion.choices.length
        ? rawChoices.length
        : completion.choices.length;
    for (int index = 0; index < choiceCount; index++) {
      final dynamic rawChoice = rawChoices[index];
      if (rawChoice is! Map) continue;
      final dynamic rawMessage = rawChoice['message'];
      if (rawMessage is! Map) continue;
      attach(
        completion.choices[index].message,
        rawMessage['encrypted_content'] as String?,
      );
    }
  }

  static void attachStreamChunk(
    Map<String, dynamic> raw,
    OpenAIStreamChatCompletionModel chunk,
  ) {
    final dynamic rawChoices = raw['choices'];
    if (rawChoices is! List) return;

    final int choiceCount = rawChoices.length < chunk.choices.length
        ? rawChoices.length
        : chunk.choices.length;
    for (int index = 0; index < choiceCount; index++) {
      final dynamic rawChoice = rawChoices[index];
      if (rawChoice is! Map) continue;
      final dynamic rawDelta = rawChoice['delta'];
      if (rawDelta is! Map) continue;
      attach(
        chunk.choices[index].delta,
        rawDelta['encrypted_content'] as String?,
      );
    }
  }
}

extension LiteOneApiChatMessageEncryptedContent
    on OpenAIChatCompletionChoiceMessageModel {
  /// The encrypted reasoning payload returned by supported Doubao Seed models.
  String? get encryptedContent => LiteOneApiEncryptedContent.read(this);

  /// Associates an encrypted reasoning payload with this message so the SDK
  /// facade replays it in the next Chat Completions request.
  OpenAIChatCompletionChoiceMessageModel withEncryptedContent(String value) {
    LiteOneApiEncryptedContent.attach(this, value);
    return this;
  }
}

extension LiteOneApiStreamDeltaEncryptedContent
    on OpenAIStreamChatCompletionChoiceDeltaModel {
  /// The encrypted reasoning payload on a streaming delta, if present.
  String? get encryptedContent => LiteOneApiEncryptedContent.read(this);
}
