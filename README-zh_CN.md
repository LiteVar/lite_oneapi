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
  lite_oneapi: ^0.3.0
```

## 使用

### 当前兼容

详情可见：`/bin/model_mapping.json`

| 官方大模型 / 厂商                                                                                                               | 接口                                   | 兼容情况 |
|----------------------------------------------------------------------------------------------------------------------------|--------------------------------------|------|
| OpenAI `gpt-6.1-sol` `gpt-6-astra` `gpt-5.5` `gpt-5.4` 及此前聊天模型                                                   | /v1/chat/completions                 | ✅    |
| Anthropic Claude `claude-*` 模型                                                                                         | `/v1/chat/completions`（Anthropic OpenAI SDK 兼容端点） | ⚠️ 有限兼容 |
| DeepSeek `deepseek-flash` `deepseek-v4-pro` 及兼容别名 `deepseek-v4-flash`                                              | /v1/chat/completions                 | ✅    |
| 豆包 Seed `doubao-seed-evolving`、Seed 2.1 和 Seed 2.0 模型                                                          | 火山方舟 `/api/v3/chat/completions`  | ✅    |
| 混元 `hy3`、`hy4-preview`（腾讯云 TokenHub）                                                                         | `/v1/chat/completions`               | ✅    |
| Qwen `qwen3.8-max` `qwen3.8-flash` `qwen3.8-omni-flash` 及更早的兼容模型                                                | /compatible-mode/v1/chat/completions | ✅    |
| MiniMax `MiniMax-M3.1-Flash` `MiniMax-M3` 及 M2.x 系列模型                                                              | OpenAI-compatible endpoint           | ✅    |
| GLM `glm-5.3` `glm-5.2` `glm-5.1` 及兼容模型                                                                           | OpenAI-compatible endpoint           | ✅    |
| Kimi `kimi-k3.1-pro` `kimi-k3` `kimi-k2.7-code` `kimi-k2.6` 和 `kimi-k2.5`                                             | OpenAI-compatible endpoint           | ✅    |
| MiMo `mimo-v2.6-pro` `mimo-v2.6-flash` `mimo-v2.6-pro-ultraspeed` 及更早模型                                           | OpenAI-compatible endpoint           | ✅    |

Anthropic 的 OpenAI SDK 兼容端点适合基本 Chat Completions 调用；`response_format`、`reasoning_effort` 和工具 `strict` 会被忽略，OpenAI SDK 响应也不包含 Claude thinking 内容。需要这些原生能力时使用 `/v1/messages`。

### 新增协议接口

三种入口分别校验、构建和转发各自协议的请求，不在协议之间转换。Responses 与 Messages 的请求字段和流式事件分别按 OpenAI、Anthropic 标准处理，厂商扩展字段会原样保留。

适配器目录按协议组织：`lib/src/adapters/chat_completions/<厂商>/`、`lib/src/adapters/responses/<厂商>/`、`lib/src/adapters/messages/<厂商>/`。每个协议自己的 `request.dart` 位于对应协议目录下；`lib/src/adapters/` 根目录保留共用的 HTTP、认证和基础适配设施。

| 入站接口 | 标准端点 | 上游适配厂商 |
|---|---|---|
| OpenAI Responses | `/v1/responses` | OpenAI、DeepSeek、千问、Kimi、豆包、混元（腾讯云 TokenHub） |
| Anthropic Messages | `/v1/messages` | Anthropic、DeepSeek、千问、智谱 GLM、Kimi、MiniMax、豆包、混元（腾讯云 TokenHub） |

#### 用 `.env` 快速测试

复制 `example/.env.example` 为 `example/.env`，填写 `GATEWAY_URL`、`API_KEY`、`MODEL` 和 `ADAPTER`，然后运行 `sh example/protocol_smoke.sh`。`PROTOCOL` 可设为 `chat`、`responses`、`messages` 或 `all`；`BASE_URL` 留空时走 `model_mapping.json`，填写时覆盖上游地址，必要时用对应的 `*_ENDPOINT` 指定厂商路径。默认 `hy3` 示例支持三种协议。

该脚本把 `API_KEY` 作为上游 key 透传。启动服务前请在 `bin/config.json` 启用 `mode.transparent`，或临时不使用 `bin/env.json`。这里的 `.env` 只供测试脚本读取；服务端的 key 池仍配置在 `bin/env.json`，模型默认路由仍配置在 `bin/model_mapping.json`。

协议支持取决于具体模型和上游产品。比如 Responses 的历史关联、内置工具和多模态能力，以及 Messages 的 thinking、内容块和工具能力，应按对应厂商当前文档和模型范围使用。混元 Responses 与 Messages 走 TokenHub；TokenHub 的 Responses 支持列表按模型区分。MiniMax 官方 Anthropic 接口目前列出的模型为 `MiniMax-M3.1-Flash` 和 `MiniMax-M3`。

网关接受 OpenAI 的 `reasoning_effort`，以及兼容别名 `enable_thinking`、`thinking.type`，并根据所选模型转换为其官方 API 参数。豆包的 `encrypted_content` 会随 assistant 消息和流式响应透传；Dart SDK facade 可通过消息的 `encryptedContent` 读取，并会在后续请求中自动回传。豆包的 `max_tokens` 与 `max_completion_tokens` 不能同时传入。混元 Hy3 的档位会映射到 `none`、`low`、`high`，Hy4 Preview 映射到 `none`、`high`。

混元默认映射到 TokenHub 广州站；新加坡站可在请求中指定 `base_url: "https://tokenhub-intl.tencentcloudmaas.com/v1"`，`hunyuan` adapter 会沿用。Responses 和 Messages 的 Kimi 默认映射使用 Moonshot 国际站 `api.moonshot.ai`，Chat Completions 保持原有路由。

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
        "anthropic": [
          {
            "type": "bearer",
            "apiKey": "Anthropic API Key"
          }
        ],
        "deepseek": [
          {
            "type": "bearer",
            "apiKey": "DeepSeek API的ApiKey，sk- 开头"
          }
        ],
        "doubao": [
          {
            "type": "bearer",
            "apiKey": "火山方舟 API Key"
          }
        ],
        "hunyuan": [
          {
            "type": "bearer",
            "apiKey": "腾讯云 TokenHub API Key"
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
- `adapter` / `channel`：强制指定 adapter，例如 `openai`、`deepseek`、`doubao`、`hunyuan`、`qwen`
- `endpoint` / `url_path` / `urlPath`：可选，显式指定转发到上游的路径
- 当传入 `base_url` 且 `model` 不在 `/bin/model_mapping.json` 中时，默认走 `openai` adapter
- 使用自定义 `base_url` 时，默认保留原始 `Authorization` header
- 使用自定义 `base_url` 时，默认保留原始 OpenAI 路径；如果需要厂商路径，可以用 `endpoint` 显式覆盖
- 如果 `base_url` 已经包含路径前缀，系统会自动补齐默认 endpoint：
  - `https://example.com/prefix` -> `https://example.com/prefix/v1/chat/completions`
  - `https://example.com/prefix/v1` -> `https://example.com/prefix/v1/chat/completions`
  - `https://example.com/prefix/v4` -> `https://example.com/prefix/v4/chat/completions`
  - `https://example.com/prefix/v1/chat/completions` -> 不再重复追加

路由优先级：
- 如果传了 `adapter` / `channel`，优先使用你指定的 adapter
- 如果没传 `adapter`，但传了 `base_url`：
  - 当 `model` 能在 `/bin/model_mapping.json` 中命中时，沿用映射里的 adapter
  - 当 `model` 不在映射中时，回退到 `openai` adapter
- 如果 `adapter` 和 `base_url` 都没传，则完全按 `/bin/model_mapping.json` 路由

示例：
- `model=deepseek-v4-pro` + `base_url` + 不传 `adapter`：使用 `deepseek` adapter，但上游地址改成你传入的地址
- `model=deepseek-v4-pro` + `base_url` + `adapter=openai`：即使模型名是 DeepSeek，也强制走 `openai` adapter
- `model=qwen-plus` + `base_url` + `adapter=qwen`：使用 `qwen` adapter，但默认请求你的上游 `/v1/chat/completions`
- `model=qwen-plus` + `base_url` + `adapter=qwen` + `endpoint=/compatible-mode/v1/chat/completions`：使用 `qwen` adapter，并显式请求通义兼容模式路径
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
   - 在`lib/src/adapters/chat_completions`目录下，新增目录`newllm`
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
   - Responses 和 Messages 厂商实现分别放在`responses/<厂商>`和`messages/<厂商>`，并注册到各自的`responsesAdapterMapper`、`messagesAdapterMapper`。
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
