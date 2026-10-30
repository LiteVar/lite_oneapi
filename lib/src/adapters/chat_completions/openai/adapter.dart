import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../adapter.dart';
import '../../request_compatibility_patch.dart';
import '../../reasoning_compatibility.dart';
import 'handler.dart';
import '../../../api/meta.dart';

class OpenAIAdapter extends LLMAdapter {
  String get providerName => 'openai';

  @override
  ResponseHandler get responseHandler => OpenAIResponseHandler();

  @override
  void init(Meta meta) {}

  @override
  String getRequestMethod(Request request, Meta meta) {
    return request.method;
  }

  @override
  String getRequestURL(Request request, Meta meta) {
    String urlPath = "/${request.url.path}";
    return buildRequestUrl(meta, urlPath);
  }

  String buildRequestUrl(Meta meta, String defaultPath) {
    final String baseUrl = meta.baseUrl.endsWith("/")
        ? meta.baseUrl.substring(0, meta.baseUrl.length - 1)
        : meta.baseUrl;

    if (meta.endpoint != null) {
      return _joinUrl(baseUrl, _pathSegments(meta.endpoint!));
    }

    final List<String> baseSegments = _basePathSegments(baseUrl);
    final List<String> defaultSegments = _pathSegments(defaultPath);
    final List<String> defaultTailSegments =
        _dropLeadingVersion(defaultSegments);

    if (_endsWithEquivalentSegments(baseSegments, defaultSegments)) {
      return baseUrl;
    }

    if (baseSegments.isNotEmpty &&
        _isVersionSegment(baseSegments.last) &&
        defaultTailSegments.isNotEmpty) {
      return _joinUrl(baseUrl, defaultTailSegments);
    }

    return _joinUrl(baseUrl, defaultSegments);
  }

  List<String> _basePathSegments(String baseUrl) {
    final Uri? uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.path.isEmpty) {
      return const [];
    }
    return uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
  }

  List<String> _pathSegments(String path) {
    return path
        .split("/")
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
  }

  List<String> _dropLeadingVersion(List<String> segments) {
    if (segments.isNotEmpty && _isVersionSegment(segments.first)) {
      return segments.skip(1).toList(growable: false);
    }
    return segments;
  }

  bool _endsWithEquivalentSegments(
      List<String> baseSegments, List<String> defaultSegments) {
    if (baseSegments.length < defaultSegments.length) {
      return false;
    }

    final int offset = baseSegments.length - defaultSegments.length;
    for (int index = 0; index < defaultSegments.length; index++) {
      final String baseSegment = baseSegments[offset + index];
      final String defaultSegment = defaultSegments[index];
      if (baseSegment == defaultSegment) {
        continue;
      }
      if (_isVersionSegment(baseSegment) && _isVersionSegment(defaultSegment)) {
        continue;
      }
      return false;
    }
    return true;
  }

  bool _isVersionSegment(String segment) {
    return RegExp(r"^v\d+$").hasMatch(segment);
  }

  String _joinUrl(String baseUrl, List<String> pathSegments) {
    if (pathSegments.isEmpty) {
      return baseUrl;
    }
    return "$baseUrl/${pathSegments.join("/")}";
  }

  @override
  Map<String, String> setupRequestHeaders(Request request, Meta meta) {
    Map<String, String> headers = {};
    headers.addAll(request.headers);
    headers.removeWhere((key, value) => key.toLowerCase() == 'x-dashscope-sse');
    if (meta.isStream) {
      if (headers["Accept"] != "text/event-stream")
        headers["Accept"] = "text/event-stream";
    } else {
      if (headers["Accept"] != "application/json")
        headers["Accept"] = "application/json";
    }

    return headers;
  }

  @override
  Future<Map<String, dynamic>> convertRequest(
      Request request, Meta meta) async {
    final Map<String, dynamic> requestBody = jsonDecode(meta.requestBody);
    ReasoningCompatibility.apply(
      body: requestBody,
      provider: providerName,
      model: meta.model,
    );
    if (providerName == 'deepseek' || providerName == 'mimo') {
      RequestCompatibilityPatch.applyReasoningContentReplayPatch(requestBody);
    }
    return requestBody;
  }

  @override
  Future<Response> doRequest(Request request, Meta meta) async {
    return await doRequestHelper(request, meta);
  }

  @override
  Future<Response> doResponse(Response response, Meta meta) async {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return response;
    }
    if (meta.isStream) {
      return responseHandler.handleStream(response);
    } else {
      return responseHandler.handle(response);
    }
  }
}
