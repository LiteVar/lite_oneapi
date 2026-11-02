## 0.3.0

- Add independent OpenAI Responses and Anthropic Messages endpoints with provider-specific adapters.
- Add Anthropic's OpenAI SDK-compatible Chat Completions endpoint.
- Organize adapters by protocol, with provider implementations under each protocol.
- Normalize OpenAI reasoning controls across provider-specific thinking APIs.
- Align provider Chat Completions fields, error handling, and authentication headers.
- Refresh model mappings and support fractional penalties in request schemas and the SDK.
- Add Doubao Ark Seed and Hunyuan TokenHub Chat Completions adapters.
- Preserve Doubao encrypted reasoning fields and normalize provider reasoning levels.

## 0.2.4

- Fix windows permission issues for log file creation

## 0.2.3

- Fix UTF-8 decoding when multibyte characters span streaming response chunks.

## 0.2.2

- fix logging performance issue on windows

## 0.2.1

- fixed adapter url endpoint issue

## 0.2.0

- Add provider adapters for DeepSeek, Qwen, MiniMax, GLM, Kimi, and MiMo.
- Support custom `base_url` and explicit `adapter` routing overrides.
- Extract reusable core gateway service and add Dart SDK facade support.
- Improve reasoning/thinking compatibility for DeepSeek and MiniMax.
- Add request and streaming normalization patches for provider compatibility.

## 0.1.0

- Initial version.
