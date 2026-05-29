# Lite OneAPI

English · [中文](README-zh_CN.md)

A lite OpenAI HTTP API-compatible transformation tool that allows custom conversion rules for LLM APIs.

## Usage

### Current Compatibility

For details, see: `/bin/model_mapping.json`

| Official Model / Provider                                                                                                      | Endpoint                             | Compatibility |
|--------------------------------------------------------------------------------------------------------------------------------|--------------------------------------|---------------|
| OpenAI `gpt-3.5` `gpt-4` `gpt-4o` `gpt-4o-mini`                                                                                | /v1/chat/completions                 | ✅             |
| DeepSeek `deepseek-v4-flash` `deepseek-v4-pro` `deepseek-chat` `deepseek-reasoner`                                            | /v1/chat/completions                 | ✅             |
| Qwen `qwq-32b` `qwen-plus` `qwen-flash` `qwen3-max` `qwen3.7-max` `qwen3.6-plus` `qwen3.5-plus` `qwen3-coder-plus` and more | /compatible-mode/v1/chat/completions | ✅             |
| MiniMax `MiniMax-M2.7` `MiniMax-M2.7-highspeed` and related M2.x models                                                       | OpenAI-compatible endpoint           | ✅             |
| GLM `glm-5.1` `glm-5.1-highspeed`                                                                                              | OpenAI-compatible endpoint           | ✅             |
| Kimi `kimi-k2.5` `kimi-k2.6`                                                                                                   | OpenAI-compatible endpoint           | ✅             |
| MiMo `mimo-v2.5-pro` `mimo-v2.5` `mimo-v2-flash` `mimo-v2-pro` `mimo-v2-omni`                                                 | OpenAI-compatible endpoint           | ✅             |

### HTTP Gateway

#### How to Use

1. If need `ApiKey` converting, in the same directory as `/bin/server.dart`, create an `env.json` file with the following format:

    ```json
    {
      "apiKeys": [
        "<Use the main() function in /lib/src/utils/apikey.dart to generate an API key>"
      ],
      "adapterKeys": {
        "openai": [
          {
            "type": "bearer",
            "apiKey": "OpenAI API Key, starting with sk-"
          }
        ],
        "deepseek": [
          {
            "type": "bearer",
            "apiKey": "DeepSeek API Key, starting with sk-"
          }
        ],
        "qwen": [
          {
            "type": "bearer",
            "apiKey": "Qwen API Key, starting with sk-"
          }
        ],
        "minimax": [
          {
            "type": "bearer",
            "apiKey": "MiniMax API key"
          }
        ],
        "glm": [
          {
            "type": "bearer",
            "apiKey": "GLM API key"
          }
        ],
        "kimi": [
          {
            "type": "bearer",
            "apiKey": "Kimi API key"
          }
        ],
        "mimo": [
          {
            "type": "bearer",
            "apiKey": "MiMo API key"
          }
        ]
      }
    }
    ```

    - Each model platform supports multiple API keys. The system automatically selects an available API key for the request and releases it immediately after use.
    - If NOT converting, NOT need `env.json` file. Or in the `config.json` file, add `mode` field, `transparent` to be `true`.

2. Run `server.dart`
3. The client sends requests using the OpenAI API.

#### Custom Base URL and Adapter Override

The gateway can route by `model`, or you can override routing per request:

```json
{
  "model": "deepseek-v4-pro",
  "base_url": "https://your-gateway.example.com/v1",
  "adapter": "openai",
  "messages": [
    {"role": "user", "content": "hello"}
  ]
}
```

- `base_url` / `baseUrl`: Use a custom upstream endpoint instead of the mapped official endpoint.
- `adapter` / `channel`: Force a specific adapter such as `openai`, `deepseek`, or `qwen`.
- If `base_url` is provided and the model is not found in `/bin/model_mapping.json`, the request defaults to the `openai` adapter.
- When using a custom `base_url`, the gateway keeps the original `Authorization` header by default.

Routing priority:
- If `adapter` / `channel` is provided, use that adapter first.
- If `adapter` is not provided but `base_url` is provided:
  - use the mapped adapter when `model` exists in `/bin/model_mapping.json`
  - otherwise fall back to the `openai` adapter
- If neither `adapter` nor `base_url` is provided, route entirely by `/bin/model_mapping.json`

Examples:
- `model=deepseek-v4-pro` + `base_url` + no `adapter`: use the `deepseek` adapter with your custom upstream
- `model=deepseek-v4-pro` + `base_url` + `adapter=openai`: force the `openai` adapter even though the model name is DeepSeek
- `model=some-aggregated-model` + `base_url` + no `adapter`: default to the `openai` adapter

This is useful for:
- OpenAI-compatible aggregators that already normalize their APIs.
- Provider-specific proxies where you still want to force a native adapter.

### Dart SDK Facade

Besides HTTP, `lite_oneapi` also provides a Dart SDK-style facade that calls the core gateway service directly without a local HTTP hop.

```dart
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
          OpenAIChatCompletionChoiceMessageContentItemModel.text('Say hello.'),
        ],
      ),
    ],
  );

  print(completion.choices.first.message.content?.first.text);

  await for (final chunk in client.chat.createStream(
    model: 'qwen-plus',
    messages: [
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text('Count to three.'),
        ],
      ),
    ],
    streamOptions: const {'include_usage': true},
  )) {
    if (chunk.choices.isEmpty) continue;
    final content = chunk.choices.first.delta.content;
    if (content != null && content.isNotEmpty) {
      print(content.first?.text);
    }
  }
}
```

Key types:
- `LiteOneApiClient`
- `LiteOneApiClientConfig`
- `client.chat.create(...)`
- `client.chat.createStream(...)`

See:
- Example: `/example/sdk_facade_example.dart`
- Tests: `/test/sdk_facade_test.dart`

### Adding a New Model

1. Create a new adapter, e.g., `NewLLMAdapter`:
    - In the `lib/src/adapters` directory, create a new folder `newllm`.
    - Inside this folder, create a `/model` subfolder and add model classes specific to the new LLM.
    - Add `adapter.dart` and implement the `LLMAdapter` class:
        - `init`: Initialize the adapter.
        - `getRequestMethod`: Modify the API request method (`GET`, `POST`, etc.).
        - `getRequestURL`: Convert request URLs.
        - `setupRequestHeaders`: Modify request headers.
        - `convertRequest`: Convert the request body.
        - `doRequest`: Add pre-processing logic before sending requests.
        - `doResponse`: Add post-processing logic after receiving responses.
    - If you need to convert the model's `application/json` and `text/event-stream` responses separately, implement `ResponseHandler`:
        - `handle`: Modify the body of `application/json` responses.
        - `handleStream`: Modify the chunks of `text/event-stream` responses.
        - If a new `ResponseHandler` is implemented, ensure `LLMAdapter` provides it:
          ```dart
          @override
          ResponseHandler get responseHandler => NewLLMResponseHandler();
          ```
2. Add the adapter to `channelAdapterMapper` in `/lib/src/config.dart`, using a lowercase name:
     ```dart
     Map<String, LLMAdapter> channelAdapterMapper = {
      /// ...
      "newllm": NewLLMAdapter(),
     };
     ```
3. Update `/bin/model_mapping.json` to map request `model-name` values to the adapter:
   ```json
   {
      "names": ["model-name-1", "model-name-2"],
      "adapter": "Name matching Step 2, e.g., newllm",
      "baseUrl": "Official API URL for the new model, e.g., https://api.newllm.com"
    }
      ```
4. Add the API key for the official API in `/bin/env.json`:
   ```json
   {
     "adapterKeys": {
       "newllm": [
         {
           "type": "bearer",
           "apiKey": "API key for the official model service, usually starting with sk-, multiple keys can be added."
         }
       ]
     }
   }
   ```
5. Run`server.dart`
6. For debugging, modify `/bin/config.json` to change the `log` `level` from `INFO` to `FINEST`, then restart `server.dart`:
   ```json
   {
     "log": {
       "level": "FINEST"
     }
   }
   ```
