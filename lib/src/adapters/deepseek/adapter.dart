import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../openai/model/chat_completions_request.dart' as oa;
import 'model/chat_completions_request.dart';
import '../../define.dart';
import '../../api/meta.dart';
import '../openai/adapter.dart';

class DeepSeekAdapter extends OpenAIAdapter {
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
      prefix: null,  /// for assistant
      reasoning_content: null, /// for assistant
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

  dynamic _convertToolChoice(dynamic tool_choice) {
    if(tool_choice is String) {
      return tool_choice;
    } else if(tool_choice is oa.Tool) {
      return _convertTool(tool_choice);
    }
  }

  String _convertContent(dynamic content) {
    if(content is String) {
      return content;
    } else if(content is List<dynamic>) {
      return _convertContentList(content);
    } else {
      return "";
    }
  }

  String _convertContentList(List<dynamic> oaContentList) {
    oa.Content oaFirstContent = oa.Content.fromJson(oaContentList.first);
    return oaFirstContent.text!;
  }
}