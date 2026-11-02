import 'dart:convert';

import 'package:dart_openai_sdk/dart_openai_sdk.dart'
    show RequestFailedException;
import 'package:shelf/shelf.dart';

import '../core/gateway_service.dart';
import 'config/client_config.dart';
import 'mapper/error_mapper.dart';

/// Shared transport only. Protocol request and event schemas remain separate.
class LiteOneApiProtocolTransport {
  final LiteOneApiClientConfig config;
  final LiteOneApiGatewayService gatewayService;

  const LiteOneApiProtocolTransport({
    required this.config,
    required this.gatewayService,
  });

  Future<Response> send({
    required String requestPath,
    required Map<String, dynamic> request,
    required Map<String, String> headers,
    required bool stream,
  }) {
    final Map<String, dynamic> body = Map<String, dynamic>.from(request)
      ..['stream'] = stream;
    if (config.baseUrl != null && config.baseUrl!.isNotEmpty) {
      body['base_url'] = config.baseUrl;
    }
    if (config.adapter != null && config.adapter!.isNotEmpty) {
      body['adapter'] = config.adapter;
    }
    if (config.endpoint != null && config.endpoint!.isNotEmpty) {
      body['endpoint'] = config.endpoint;
    }

    return gatewayService.handleJsonRequest(
      payload: jsonEncode(body),
      requestPath: requestPath,
      requestHeaders: headers,
    );
  }

  static Future<Map<String, dynamic>> readJsonResponse(
    Response response, {
    required String protocol,
  }) async {
    final String body = await response.readAsString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RequestFailedException(
        LiteOneApiErrorMapper.extractErrorMessage(
          body,
          statusCode: response.statusCode,
        ),
        response.statusCode,
      );
    }

    final dynamic decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException(
        'lite_oneapi returned a non-object $protocol response.',
      );
    }
    LiteOneApiErrorMapper.throwIfBusinessErrorMap(
      decoded,
      statusCode: response.statusCode,
    );
    return decoded;
  }

  static Future<void> ensureStreamResponse(Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    final String body = await response.readAsString();
    throw RequestFailedException(
      LiteOneApiErrorMapper.extractErrorMessage(
        body,
        statusCode: response.statusCode,
      ),
      response.statusCode,
    );
  }
}
