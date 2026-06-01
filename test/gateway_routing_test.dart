import 'dart:convert';

import 'package:lite_oneapi/lite_oneapi.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('Gateway routing overrides', () {
    test('custom base_url keeps OpenAI path while preserving provider adapter',
        () {
      final service = LiteOneApiGatewayService();
      final prepared = service.prepareRequest(
        payload: jsonEncode({
          'model': 'qwen-plus',
          'base_url': 'https://proxy.example.com/v1',
          'adapter': 'qwen',
          'messages': [
            {'role': 'user', 'content': 'hello'},
          ],
        }),
        requestPath: '/v1/chat/completions',
        requestHeaders: {'Authorization': 'Bearer sk-test'},
      );

      final request =
          Request('POST', Uri.parse('http://localhost/v1/chat/completions'));

      expect(prepared.meta.adapterName, 'qwen');
      expect(prepared.adapter.getRequestURL(request, prepared.meta),
          'https://proxy.example.com/v1/chat/completions');
    });

    test('mapped provider still uses provider endpoint without custom base_url',
        () {
      final service = LiteOneApiGatewayService();
      final prepared = service.prepareRequest(
        payload: jsonEncode({
          'model': 'qwen-plus',
          'messages': [
            {'role': 'user', 'content': 'hello'},
          ],
        }),
        requestPath: '/v1/chat/completions',
        requestHeaders: {'Authorization': 'Bearer sk-test'},
      );

      final request =
          Request('POST', Uri.parse('http://localhost/v1/chat/completions'));

      expect(prepared.adapter.getRequestURL(request, prepared.meta),
          'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions');
    });

    test('endpoint explicitly overrides path for custom base_url', () {
      final service = LiteOneApiGatewayService();
      final prepared = service.prepareRequest(
        payload: jsonEncode({
          'model': 'qwen-plus',
          'base_url': 'https://dashscope-proxy.example.com',
          'adapter': 'qwen',
          'endpoint': '/compatible-mode/v1/chat/completions',
          'messages': [
            {'role': 'user', 'content': 'hello'},
          ],
        }),
        requestPath: '/v1/chat/completions',
        requestHeaders: {'Authorization': 'Bearer sk-test'},
      );

      final request =
          Request('POST', Uri.parse('http://localhost/v1/chat/completions'));

      expect(
        prepared.adapter.getRequestURL(request, prepared.meta),
        'https://dashscope-proxy.example.com/compatible-mode/v1/chat/completions',
      );
    });

    test('base_url with prefix path appends default chat completions path', () {
      final service = LiteOneApiGatewayService();
      final prepared = service.prepareRequest(
        payload: jsonEncode({
          'model': 'gpt-4o-mini',
          'base_url': 'https://proxy.example.com:8443/provider/openai',
          'adapter': 'openai',
          'messages': [
            {'role': 'user', 'content': 'hello'},
          ],
        }),
        requestPath: '/v1/chat/completions',
        requestHeaders: {'Authorization': 'Bearer sk-test'},
      );

      final request =
          Request('POST', Uri.parse('http://localhost/v1/chat/completions'));

      expect(prepared.adapter.getRequestURL(request, prepared.meta),
          'https://proxy.example.com:8443/provider/openai/v1/chat/completions');
    });

    test('base_url ending in version appends chat completions path', () {
      final service = LiteOneApiGatewayService();
      final prepared = service.prepareRequest(
        payload: jsonEncode({
          'model': 'gpt-4o-mini',
          'base_url': 'https://proxy.example.com/provider/openai/v4',
          'adapter': 'openai',
          'messages': [
            {'role': 'user', 'content': 'hello'},
          ],
        }),
        requestPath: '/v1/chat/completions',
        requestHeaders: {'Authorization': 'Bearer sk-test'},
      );

      final request =
          Request('POST', Uri.parse('http://localhost/v1/chat/completions'));

      expect(prepared.adapter.getRequestURL(request, prepared.meta),
          'https://proxy.example.com/provider/openai/v4/chat/completions');
    });

    test('base_url with complete endpoint does not append again', () {
      final service = LiteOneApiGatewayService();
      final prepared = service.prepareRequest(
        payload: jsonEncode({
          'model': 'gpt-4o-mini',
          'base_url':
              'https://proxy.example.com/provider/openai/v1/chat/completions',
          'adapter': 'openai',
          'messages': [
            {'role': 'user', 'content': 'hello'},
          ],
        }),
        requestPath: '/v1/chat/completions',
        requestHeaders: {'Authorization': 'Bearer sk-test'},
      );

      final request =
          Request('POST', Uri.parse('http://localhost/v1/chat/completions'));

      expect(prepared.adapter.getRequestURL(request, prepared.meta),
          'https://proxy.example.com/provider/openai/v1/chat/completions');
    });
  });
}
