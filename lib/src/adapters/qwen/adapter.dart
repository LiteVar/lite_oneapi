import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../openai/model/chat_completions_request.dart' as oa;
import 'model/chat_completions_request.dart';
import '../../api/meta.dart';
import '../../define.dart';
import '../openai/adapter.dart';

class QwenAdapter extends OpenAIAdapter {

  @override
  String getRequestURL(Request request, Meta meta) {
    /// "/v1/chat/completions" to "/compatible-mode/v1/chat/completions"
    String urlPath = "/compatible-mode/${request.url.path}";
    return "${meta.baseUrl}$urlPath";
  }

  @override
  Future<Map<String, dynamic>> convertRequest(Request request, Meta meta) async {
    /// TODO: add request body convert here for your need
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
      model: oaRequest.model,
      messages: oaRequest.messages.map((oaMessage)=>_convertMessage(oaMessage)).toList(),
      stream: oaRequest.stream,
      stream_options: _convertStreamOptions(oaRequest.stream_options),
      modalities: oaRequest.modalities,
      temperature: oaRequest.temperature,
      top_p: oaRequest.top_p,
      presence_penalty: oaRequest.presence_penalty,
      response_format: _convertResponseFormat(oaRequest.response_format),
      max_tokens: oaRequest.max_tokens??oaRequest.max_completion_tokens,
      n: oaRequest.n,
      seed: oaRequest.seed,
      stop: oaRequest.stop,
      tools: oaRequest.tools?.map((oaTool)=>_convertTool(oaTool)).toList(),
      tool_choice: _convertToolChoice(oaRequest.tool_choice),
      parallel_tool_calls: oaRequest.parallel_tool_calls,
      translation_options: null,
      enable_search: oaRequest.web_search_options == null? null: true,
      x_dashScope_dataInspection: null,
    );
  }
  
  Message _convertMessage(oa.Message oaMessage) {
    return Message(
      role: oaMessage.role,
      content: oaMessage.content,
      partial: null,
      tool_calls: oaMessage.tool_calls?.map((oaToolCall)=>_convertToolCall(oaToolCall)).toList(),
      tool_call_id: oaMessage.tool_call_id,
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
    );
  }

  dynamic _convertToolChoice(dynamic tool_choice) {
    if(tool_choice is String) {
      return tool_choice;
    } else if(tool_choice is oa.Tool) {
      return _convertTool(tool_choice);
    }
  }

}

