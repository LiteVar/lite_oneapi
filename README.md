# Lite OneAPI

English · [中文](README-zh_CN.md)

A lite OpenAI HTTP API-compatible transformation tool that allows custom conversion rules for LLM APIs.

## Usage

### Current Compatibility

For details, see: `/bin/model_mapping.json`

| Official Model                                  | Endpoint                             | Compatibility |
|-------------------------------------------------|--------------------------------------|---------------|
| OpenAI `gpt-3.5` `gpt-4` `gpt-4o` `gpt-4o-mini` | /v1/chat/completions                 | ✅             |
| DeepSeek `deepseek-chat` `deepseek-reason`      | /v1/chat/completions                 | ✅             |
| Qwen `qwq-32b`                                  | /compatible-mode/v1/chat/completions | ✅             |

### How to Use

1. In the same directory as `/bin/server.dart`, create an `env.json` file with the following format:

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
        ]
      }
    }
    ```

    - Each model platform supports multiple API keys. The system automatically selects an available API key for the request and releases it immediately after use.

2. Run `server.dart`
3. The client sends requests using the OpenAI API.

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