# Lite OneAPI

[English](README.md) · 中文

一个轻量级的OpenAI HTTP API兼容转换工具，可以自定义大模型API的转换规则

## 安装

通过 pub.dev 安装 `lite_oneapi`：

```bash
dart pub add lite_oneapi
```

或者在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  lite_oneapi: ^0.2.0
```

## 使用

### 当前兼容

详情可见：`/bin/model_mapping.json`

| 官方大模型 / 厂商                                                                                                               | 接口                                   | 兼容情况 |
|----------------------------------------------------------------------------------------------------------------------------|--------------------------------------|------|
| OpenAI `gpt-3.5` `gpt-4` `gpt-4o` `gpt-4o-mini`                                                                            | /v1/chat/completions                 | ✅    |
| DeepSeek `deepseek-v4-flash` `deepseek-v4-pro` `deepseek-chat` `deepseek-reasoner`                                        | /v1/chat/completions                 | ✅    |
| Qwen `qwq-32b` `qwen-plus` `qwen-flash` `qwen3-max` `qwen3.7-max` `qwen3.6-plus` `qwen3.5-plus` `qwen3-coder-plus` 等模型 | /compatible-mode/v1/chat/completions | ✅    |
| MiniMax `MiniMax-M2.7` `MiniMax-M2.7-highspeed` 及相关 M2.x 模型                                                           | OpenAI-compatible endpoint           | ✅    |
| GLM `glm-5.1` `glm-5.1-highspeed`                                                                                          | OpenAI-compatible endpoint           | ✅    |
| Kimi `kimi-k2.5` `kimi-k2.6`                                                                                               | OpenAI-compatible endpoint           | ✅    |
| MiMo `mimo-v2.5-pro` `mimo-v2.5` `mimo-v2-flash` `mimo-v2-pro` `mimo-v2-omni`                                             | OpenAI-compatible endpoint           | ✅    |

### HTTP 网关

#### 使用方法

1. 如果使用`ApiKey`转换，则需要在`/bin/server.dart`同级目录，创建`env.json`，格式如下：

    ```json
    {
      "apiKeys": [
        "<使用 /lib/src/utils/apikey.dart 的main()协助生成apiKey>"
      ],
      "adapterKeys": {
        "openai": [
          {
            "type": "bearer",
            "apiKey": "OpenAI API的ApiKey，sk- 开头"
          }
        ],
        "deepseek": [
          {
            "type": "bearer",
            "apiKey": "DeepSeek API的ApiKey，sk- 开头"
          }
        ],
        "qwen": [
          {
            "type": "bearer",
            "apiKey": "通义千问API的ApiKey，sk- 开头"
          }
        ],
        "minimax": [
          {
            "type": "bearer",
            "apiKey": "MiniMax API的ApiKey"
          }
        ],
        "glm": [
          {
            "type": "bearer",
            "apiKey": "GLM API的ApiKey"
          }
        ],
        "kimi": [
          {
            "type": "bearer",
            "apiKey": "Kimi API的ApiKey"
          }
        ],
        "mimo": [
          {
            "type": "bearer",
            "apiKey": "MiMo API的ApiKey"
          }
        ]
      }
    }
    ```
   - 每个大模型平台下，支持多个ApiKey，系统会自动选择没有被占用的ApiKey进行请求，请求后立刻释放
   - 如果直接使用透传模式，则不需要创建`env.json`文件，或是config.json中，具有`mode`字段，`transparent`为`true`

2. 运行`server.dart`
3. 客户端使用OpenAI API发起请求

#### 自定义 Base URL 和 Adapter

除了按 `model` 自动路由，也可以在单次请求中显式指定上游地址和协议：

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

- `base_url` / `baseUrl`：优先使用你传入的上游地址，而不是 `/bin/model_mapping.json` 中的官方地址
- `adapter` / `channel`：强制指定 adapter，例如 `openai`、`deepseek`、`qwen`
- 当传入 `base_url` 且 `model` 不在 `/bin/model_mapping.json` 中时，默认走 `openai` adapter
- 使用自定义 `base_url` 时，默认保留原始 `Authorization` header

路由优先级：
- 如果传了 `adapter` / `channel`，优先使用你指定的 adapter
- 如果没传 `adapter`，但传了 `base_url`：
  - 当 `model` 能在 `/bin/model_mapping.json` 中命中时，沿用映射里的 adapter
  - 当 `model` 不在映射中时，回退到 `openai` adapter
- 如果 `adapter` 和 `base_url` 都没传，则完全按 `/bin/model_mapping.json` 路由

示例：
- `model=deepseek-v4-pro` + `base_url` + 不传 `adapter`：使用 `deepseek` adapter，但上游地址改成你传入的地址
- `model=deepseek-v4-pro` + `base_url` + `adapter=openai`：即使模型名是 DeepSeek，也强制走 `openai` adapter
- `model=some-aggregated-model` + `base_url` + 不传 `adapter`：默认走 `openai` adapter

适用场景：
- 已经做过接口规整化的聚合厂商
- 想保留厂商原生 adapter 逻辑的自建代理地址

### Dart SDK Facade

除了 HTTP 用法，`lite_oneapi` 还提供了一层 Dart SDK 风格 facade，直接调用 core service，不需要经过本地 HTTP 中转。

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

关键类型：
- `LiteOneApiClient`
- `LiteOneApiClientConfig`
- `client.chat.create(...)`
- `client.chat.createStream(...)`

参考：
- 示例：`/example/sdk_facade_example.dart`
- 测试：`/test/sdk_facade_test.dart`

### 新增大模型

1. 新增Adapter，假设为：`NewLLMAdapter`
   - 在`lib/src/adapters`目录下，新增目录`newllm`
   - 新增`/model`文件夹，文件夹内新增针对新增大模型的model类
   - 新增`adapter.dart`，实现`LLMAdapter`类
      - `init`：可初始化Adapter
      - `getRequestMethod`: 可修改API请求的"GET" "POST"等方法
      - `getRequestURL`: 可转换请求的URL
      - `setupRequestHeaders`: 可转换请求的Headers
      - `convertRequest`: 可转换请求中的requestBody
      - `doRequest`: 在执行请求前，可以增加执行所需代码
      - `doResponse`: 在获得回复后，可增加执行所需代码
   - 如果需要分别转换大模型返回的`application/json`和`text/event-stream`，则可实现`ResponseHandler`
      - `handle`: 可转换`application/json`的返回body的内容
      - `handleStream`: 可转换`text/event-stream`的返回chunk的内容
      - 若有新的ResponseHandler，需要实现LLMAdapter的responseHandler的get：
        ```dart
        @override
        ResponseHandler get responseHandler => NewLLMResponseHandler();
        ```
2. 在`/lib/src/config.dart`中的`channelAdapterMapper`，增加名称和Adapter的匹配，建议全小写：
     ```dart
     Map<String, LLMAdapter> channelAdapterMapper = {
      /// ...
      "newllm": NewLLMAdapter(),
     };
     ```
3. 在`/bin/model_mapping.json`中，新增配置，用于对应系统在收到请求的`model-name`时，匹配到对应的Adapter：
   ```json
   {
      "names": ["model-name-1", "model-name-2"],
      "adapter": "步骤2对应的名称，例如：newlllm",
      "baseUrl": "新增大模型对应的官方URL，例如：https://api.newllm.com"
    }
   ```
4. 在`/bin/env.json`中，增加请求官方URL时的ApiKey：
   ```json
   {
     "adapterKeys": {
       "newllm": [
         {
           "type": "bearer",
           "apiKey": "请求官方URL时的ApiKey，一般以 sk- 开头，可增加多个"
         }
       ]
     }
   }
   ```
5. 运行`server.dart`
6. 调试日志，修改`/bin/config.json`，`log`的`level`从`INFO`改为`FINEST`，并重新运行`server.dart`例如：
   ```json
   {
     "log": {
       "level": "FINEST"
     }
   }
   ```
