# Lite OneAPI

English · [中文](README-zh_CN.md)

A lite OpenAI HTTP API-compatible transformation tool that allows custom conversion rules for LLM APIs.

## Install

Add `lite_oneapi` from pub.dev:

```bash
dart pub add lite_oneapi
```

or:

```yaml
dependencies:
  lite_oneapi: ^0.3.0
```

## Usage

### Current Compatibility

For details, see: `/bin/model_mapping.json`

| Official Model / Provider                                                                                                      | Endpoint                             | Compatibility |
|--------------------------------------------------------------------------------------------------------------------------------|--------------------------------------|---------------|
| OpenAI `gpt-6.1-sol` `gpt-6-astra` `gpt-5.5` `gpt-5.4` and earlier chat models                                              | /v1/chat/completions                 | ✅             |
| DeepSeek `deepseek-flash` `deepseek-v4-pro` and the `deepseek-v4-flash` compatibility alias                               | /v1/chat/completions                 | ✅             |
| Doubao Seed `doubao-seed-evolving`, Seed 2.1, and Seed 2.0 models                                                         | Volcengine Ark `/api/v3/chat/completions` | ✅        |
| Hunyuan `hy3` and `hy4-preview` (Tencent Cloud TokenHub)                                                                   | `/v1/chat/completions`               | ✅             |
| Qwen `qwen3.8-max` `qwen3.8-flash` `qwen3.8-omni-flash` and earlier compatible models                                      | /compatible-mode/v1/chat/completions | ✅             |
| MiniMax `MiniMax-M3.1-Flash` `MiniMax-M3` and M2.x models                                                                   | OpenAI-compatible endpoint           | ✅             |
| GLM `glm-5.3` `glm-5.2` `glm-5.1` and compatible models                                                                     | OpenAI-compatible endpoint           | ✅             |
| Kimi `kimi-k3.1-pro` `kimi-k3` `kimi-k2.7-code` `kimi-k2.6` and `kimi-k2.5`                                               | OpenAI-compatible endpoint           | ✅             |
| MiMo `mimo-v2.6-pro` `mimo-v2.6-flash` `mimo-v2.6-pro-ultraspeed` and earlier models                                      | OpenAI-compatible endpoint           | ✅             |

The gateway accepts OpenAI `reasoning_effort` and the compatibility aliases `enable_thinking` and `thinking.type`. It maps these controls to each routed model's documented API. Doubao `encrypted_content` is preserved in assistant messages and streaming responses; the Dart SDK facade exposes it as `encryptedContent` on the message and replays it automatically in later requests. Doubao requests cannot include both `max_tokens` and `max_completion_tokens`. Hunyuan effort levels map to `none` / `low` / `high` for Hy3 and `none` / `high` for Hy4 Preview.

Hunyuan mappings default to Tencent TokenHub's Guangzhou endpoint. For the Singapore endpoint, set `base_url` to `https://tokenhub-intl.tencentmaas.com/v1`; the `hunyuan` adapter is retained.

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
        "doubao": [
          {
            "type": "bearer",
            "apiKey": "Volcengine Ark API key"
          }
        ],
        "hunyuan": [
          {
            "type": "bearer",
            "apiKey": "Tencent Cloud TokenHub API key"
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
- `adapter` / `channel`: Force a specific adapter such as `openai`, `deepseek`, `doubao`, `hunyuan`, or `qwen`.
- `endpoint` / `url_path` / `urlPath`: Optional upstream path override.
- If `base_url` is provided and the model is not found in `/bin/model_mapping.json`, the request defaults to the `openai` adapter.
- When using a custom `base_url`, the gateway keeps the original `Authorization` header by default.
- When using a custom `base_url`, the gateway keeps the original OpenAI path by default; use `endpoint` when you need a provider-specific path.
- If `base_url` already contains a path prefix, the gateway completes the default endpoint automatically:
  - `https://example.com/prefix` -> `https://example.com/prefix/v1/chat/completions`
  - `https://example.com/prefix/v1` -> `https://example.com/prefix/v1/chat/completions`
  - `https://example.com/prefix/v4` -> `https://example.com/prefix/v4/chat/completions`
  - `https://example.com/prefix/v1/chat/completions` -> no extra suffix is appended

Routing priority:
- If `adapter` / `channel` is provided, use that adapter first.
- If `adapter` is not provided but `base_url` is provided:
  - use the mapped adapter when `model` exists in `/bin/model_mapping.json`
  - otherwise fall back to the `openai` adapter
- If neither `adapter` nor `base_url` is provided, route entirely by `/bin/model_mapping.json`

Examples:
- `model=deepseek-v4-pro` + `base_url` + no `adapter`: use the `deepseek` adapter with your custom upstream
- `model=deepseek-v4-pro` + `base_url` + `adapter=openai`: force the `openai` adapter even though the model name is DeepSeek
- `model=qwen-plus` + `base_url` + `adapter=qwen`: use the `qwen` adapter while calling your upstream `/v1/chat/completions`
- `model=qwen-plus` + `base_url` + `adapter=qwen` + `endpoint=/compatible-mode/v1/chat/completions`: use the `qwen` adapter and explicitly call the Qwen compatible-mode path
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
