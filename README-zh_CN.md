# Lite OneAPI

[English](README.md) · 中文

一个轻量级的OpenAI HTTP API兼容转换工具，可以自定义大模型API的转换规则

## 使用

### 当前兼容

详情可见：`/bin/model_mapping.json`

| 官方大模型                                           | 接口                                   | 兼容情况 |
|-------------------------------------------------|--------------------------------------|------|
| OpenAI `gpt-3.5` `gpt-4` `gpt-4o` `gpt-4o-mini` | /v1/chat/completions                 | ✅    |
| DeepSeek `deepseek-chat` `deepseek-reason`      | /v1/chat/completions                 | ✅    |
| Qwen `qwq-32b`                                  | /compatible-mode/v1/chat/completions | ✅    |

### 使用方法

1. 在`/bin/server.dart`同级目录，创建`env.json`，格式如下：

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
        ]
      }
    }
    ```
   
   - 每个大模型平台下，支持多个ApiKey，系统会自动选择没有被占用的ApiKey进行请求，请求后立刻释放 

2. 运行`server.dart`
3. 客户端使用OpenAI API发起请求

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