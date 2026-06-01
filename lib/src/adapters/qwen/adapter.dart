import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../openai/model/chat_completions_request.dart' as oa;
import '../exception.dart';
import 'model/chat_completions_request.dart';
import '../../api/meta.dart';
import '../../define.dart';
import '../openai/adapter.dart';

class QwenAdapter extends OpenAIAdapter {
  @override
  String getRequestURL(Request request, Meta meta) {
    /// "/v1/chat/completions" to "/compatible-mode/v1/chat/completions"
    String urlPath = meta.isCustomBaseUrl
        ? "/${request.url.path}"
        : "/compatible-mode/${request.url.path}";
    return buildRequestUrl(meta, urlPath);
  }

  @override
  Future<Map<String, dynamic>> convertRequest(
      Request request, Meta meta) async {
    Map<String, dynamic> data = jsonDecode(meta.requestBody);

    if (meta.mode == RelayMode.ChatCompletions) {
      return _relayChatCompletions(data);
    }
    return data;
  }

  Map<String, dynamic> _relayChatCompletions(Map<String, dynamic> data) {
    oa.ChatCompletionRequest oaRequestBody =
        oa.ChatCompletionRequest.fromJson(data);
    _validateRequest(oaRequestBody);

    Map<String, dynamic> requestBody = Map<String, dynamic>.from(data);
    requestBody["messages"] = oaRequestBody.messages
        .map((oaMessage) => _convertMessage(oaMessage))
        .toList();

    if (requestBody["max_tokens"] == null &&
        oaRequestBody.max_completion_tokens != null) {
      requestBody["max_tokens"] = oaRequestBody.max_completion_tokens;
    }

    if (requestBody["enable_search"] == null &&
        oaRequestBody.web_search_options != null) {
      requestBody["enable_search"] = true;
    }

    if (requestBody["tools"] == null && oaRequestBody.functions != null) {
      requestBody["tools"] = oaRequestBody.functions!
          .map((oaFunction) => _convertFunctionToTool(oaFunction).toJson())
          .toList();
    }

    if (requestBody["tool_choice"] == null &&
        oaRequestBody.function_call != null) {
      requestBody["tool_choice"] =
          _convertDeprecatedFunctionCall(oaRequestBody.function_call);
    }

    requestBody.remove("functions");
    requestBody.remove("function_call");
    requestBody.remove("max_completion_tokens");
    requestBody.remove("web_search_options");

    return requestBody;
  }

  void _validateRequest(oa.ChatCompletionRequest oaRequest) {
    if (oaRequest.response_format?.type == "json_schema") {
      throw UnsupportedRequestException(
        "Qwen compatible-mode chat completions does not support `response_format.type = json_schema`.",
      );
    }
  }

  Map<String, dynamic> _convertMessage(oa.Message oaMessage) {
    return {
      "role": oaMessage.role,
      if (oaMessage.content != null) "content": oaMessage.content,
      if (oaMessage.name != null) "name": oaMessage.name,
      if (oaMessage.tool_calls != null)
        "tool_calls": oaMessage.tool_calls!
            .map((oaToolCall) => _convertToolCall(oaToolCall).toJson())
            .toList(),
      if (oaMessage.tool_call_id != null)
        "tool_call_id": oaMessage.tool_call_id,
      if (oaMessage.refusal != null) "refusal": oaMessage.refusal,
    };
  }

  ToolCall _convertToolCall(oa.ToolCall oaToolCall) {
    return ToolCall(
        function: _convertFunctionCalledModel(oaToolCall.function),
        id: oaToolCall.id,
        type: oaToolCall.type);
  }

  FunctionCalledModel _convertFunctionCalledModel(
      oa.FunctionCalledModel oaFunctionCalledModel) {
    return FunctionCalledModel(
        name: oaFunctionCalledModel.name,
        arguments: oaFunctionCalledModel.arguments);
  }

  Tool _convertFunctionToTool(oa.FunctionModel oaFunctionModel) {
    return Tool(
      type: "function",
      function: _convertFunctionModel(oaFunctionModel),
    );
  }

  FunctionModel _convertFunctionModel(oa.FunctionModel oaFunctionModel) {
    return FunctionModel(
      name: oaFunctionModel.name,
      description: oaFunctionModel.description,
      parameters: oaFunctionModel.parameters,
    );
  }

  dynamic _convertDeprecatedFunctionCall(dynamic functionCall) {
    if (functionCall is String) {
      return functionCall;
    } else if (functionCall is oa.FunctionCall) {
      return {
        "type": "function",
        "function": {
          "name": functionCall.name,
        }
      };
    }
    return functionCall;
  }
}
