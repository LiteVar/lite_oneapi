import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../openai/model/chat_completions_request.dart' as oa;
import '../exception.dart';
import 'model/chat_completions_request.dart';
import '../../define.dart';
import '../../api/meta.dart';
import '../openai/adapter.dart';

class DeepSeekAdapter extends OpenAIAdapter {
  @override
  void init(Meta meta) {
    if(meta.mode != RelayMode.ChatCompletions) return;

    oa.ChatCompletionRequest requestBody = oa.ChatCompletionRequest.fromJson(jsonDecode(meta.requestBody));
    if(_usesBetaFeatures(requestBody) && !meta.baseUrl.endsWith("/beta")) {
      meta.baseUrl = "${meta.baseUrl}/beta";
    }
  }

  @override
  Future<Map<String, dynamic>> convertRequest(Request request, Meta meta) async {
    Map<String, dynamic> data = jsonDecode(meta.requestBody);

    if(meta.mode == RelayMode.ChatCompletions) {
      return _relayChatCompletions(data);
    }
    return data;
  }

  Map<String, dynamic> _relayChatCompletions(Map<String, dynamic> data) {
    oa.ChatCompletionRequest oaRequestBody = oa.ChatCompletionRequest.fromJson(data);
    ChatCompletionRequest requestBody = _convertRequest(oaRequestBody);
    return requestBody.toJson();
  }

  ChatCompletionRequest _convertRequest(oa.ChatCompletionRequest oaRequest) {
    return ChatCompletionRequest(
      messages: oaRequest.messages.map((message)=>_convertMessage(message)).toList(),
      model: oaRequest.model,
      frequency_penalty: oaRequest.frequency_penalty,
      max_tokens: oaRequest.max_tokens??oaRequest.max_completion_tokens,
      presence_penalty: oaRequest.presence_penalty,
      thinking: _convertThinking(oaRequest.thinking),
      reasoning_effort: oaRequest.reasoning_effort,
      response_format: _convertResponseFormat(oaRequest.response_format),
      stop: oaRequest.stop,
      stream: oaRequest.stream,
      stream_options: _convertStreamOptions(oaRequest.stream_options),
      temperature: oaRequest.temperature,
      tool_choice: _convertToolChoice(oaRequest.tool_choice),
      top_p: oaRequest.top_p,
      tools: oaRequest.tools?.map((tool)=>_convertTool(tool)).toList(),
      logprobs: oaRequest.logprobs,
      top_logprobs: oaRequest.top_logprobs
    );
  }

  Message _convertMessage(oa.Message oaMessage) {
    String oaRole = oaMessage.role;
    if(oaRole == oa.RoleType.DEVELOPER) {
      oaRole = RoleType.SYSTEM;
    }

    return Message(
      role: oaRole,
      content: _convertContent(oaMessage.content),
      name: oaMessage.name,
      prefix: oaMessage.prefix,
      reasoning_content: oaMessage.reasoning_content,
      tool_calls: oaMessage.tool_calls?.map((oaToolCall) => _convertToolCall(oaToolCall)).toList(), /// for assistant
      tool_call_id: oaMessage.tool_call_id /// for tool
    );
  }

  ToolCall _convertToolCall(oa.ToolCall oaToolCall) {
    return ToolCall(
      function: _convertFunctionCalledModel(oaToolCall.function),
      id: oaToolCall.id,
      type: oaToolCall.type
    );
  }

  FunctionCalledModel _convertFunctionCalledModel(oa.FunctionCalledModel oaFunctionCalledModel) {
    return FunctionCalledModel(
      name: oaFunctionCalledModel.name,
      arguments: oaFunctionCalledModel.arguments
    );
  }

  ResponseFormat? _convertResponseFormat(oa.ResponseFormat? oaResponseFormat) {
    if(oaResponseFormat == null) return null;
    return ResponseFormat(
      type: oaResponseFormat.type,
    );
  }

  StreamOptions? _convertStreamOptions(oa.StreamOptions? oaStreamOptions) {
    if(oaStreamOptions == null) return null;
    return StreamOptions(
      include_usage: oaStreamOptions.include_usage
    );
  }

  Tool _convertTool(oa.Tool oaTool) {
    return Tool(
      type: oaTool.type,
      function: _convertFunctionModel(oaTool.function)
    );
  }

  FunctionModel _convertFunctionModel(oa.FunctionModel oaFunctionModel) {
    return FunctionModel(
      name: oaFunctionModel.name,
      description: oaFunctionModel.description,
      parameters: oaFunctionModel.parameters,
      strict: oaFunctionModel.strict,
    );
  }

  Thinking? _convertThinking(oa.Thinking? oaThinking) {
    if(oaThinking == null) return null;
    return Thinking(
      type: oaThinking.type,
    );
  }

  dynamic _convertToolChoice(dynamic tool_choice) {
    if(tool_choice is String) {
      return tool_choice;
    } else if(tool_choice is oa.Tool) {
      return _convertTool(tool_choice);
    }
  }

  bool _usesBetaFeatures(oa.ChatCompletionRequest requestBody) {
    return requestBody.messages.any((message) {
      return message.prefix == true || message.reasoning_content != null;
    });
  }

  String _convertContent(dynamic content) {
    if(content is String) {
      return content;
    } else if(content is List<dynamic>) {
      return _convertContentList(content);
    } else {
      throw UnsupportedRequestException("DeepSeek chat completions only supports text content messages.");
    }
  }

  String _convertContentList(List<dynamic> oaContentList) {
    List<String> textParts = [];

    for(final dynamic item in oaContentList) {
      oa.Content contentItem = oa.Content.fromJson(item as Map<String, dynamic>);
      if(contentItem.type == "text" && contentItem.text != null) {
        textParts.add(contentItem.text!);
        continue;
      }
      throw UnsupportedRequestException(
        "DeepSeek chat completions currently only supports text content parts, but received `${contentItem.type}`.",
      );
    }

    return textParts.join("\n");
  }
}
