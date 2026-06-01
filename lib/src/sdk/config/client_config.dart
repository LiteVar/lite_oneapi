class LiteOneApiClientConfig {
  final String? apiKey;
  final String? baseUrl;
  final String? adapter;
  final String? endpoint;
  final Map<String, String> headers;
  final String chatCompletionsPath;

  const LiteOneApiClientConfig({
    this.apiKey,
    this.baseUrl,
    this.adapter,
    this.endpoint,
    this.headers = const {},
    this.chatCompletionsPath = '/v1/chat/completions',
  });

  LiteOneApiClientConfig copyWith({
    String? apiKey,
    String? baseUrl,
    String? adapter,
    String? endpoint,
    Map<String, String>? headers,
    String? chatCompletionsPath,
  }) {
    return LiteOneApiClientConfig(
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      adapter: adapter ?? this.adapter,
      endpoint: endpoint ?? this.endpoint,
      headers: headers ?? this.headers,
      chatCompletionsPath: chatCompletionsPath ?? this.chatCompletionsPath,
    );
  }
}
