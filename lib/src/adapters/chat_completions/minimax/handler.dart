import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../../adapter.dart';
import '../../streaming_response_normalizer.dart';

class MiniMaxResponseHandler implements ResponseHandler {
  @override
  Response handle(Response response) {
    final Future<List<int>> rewrittenBody =
        response.readAsString().then((String body) {
      final dynamic decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        return utf8.encode(body);
      }
      final Map<String, dynamic> rewritten =
          _rewriteCompletionResponse(decoded);
      return utf8.encode(jsonEncode(rewritten));
    });

    return response.change(
      body: Stream<List<int>>.fromFuture(rewrittenBody),
      headers: {
        ...response.headers,
        'content-type': 'application/json',
      },
    );
  }

  @override
  Response handleStream(Response response) {
    final Stream<List<int>> transformed = _transformSse(response.read());
    return response.change(
      body: transformed,
      headers: {
        ...response.headers,
        'content-type': 'text/event-stream',
      },
    );
  }

  Map<String, dynamic> _rewriteCompletionResponse(Map<String, dynamic> json) {
    final dynamic choices = json['choices'];
    if (choices is! List) {
      return json;
    }

    for (final dynamic choice in choices) {
      if (choice is! Map<String, dynamic>) {
        continue;
      }
      final dynamic message = choice['message'];
      if (message is! Map<String, dynamic>) {
        continue;
      }

      final _ReasoningProjection projection = _projectNonStreamMessage(message);
      if (projection.content != null) {
        message['content'] = projection.content;
      }
      if (projection.reasoningContent != null &&
          projection.reasoningContent!.isNotEmpty) {
        message['reasoning_content'] = _mergeText(
          message['reasoning_content'] as String?,
          projection.reasoningContent!,
        );
      }
      message.remove('reasoning_details');
    }

    return StreamingResponseNormalizer.normalizeChunk(json);
  }

  Stream<List<int>> _transformSse(Stream<List<int>> stream) async* {
    final StringBuffer buffer = StringBuffer();
    final Map<String, _MiniMaxStreamState> stateByChoice =
        <String, _MiniMaxStreamState>{};

    await for (final String chunk in utf8.decoder.bind(stream)) {
      buffer.write(chunk);
      String current = buffer.toString();
      int delimiterIndex = current.indexOf('\n\n');

      while (delimiterIndex != -1) {
        final String frame = current.substring(0, delimiterIndex);
        current = current.substring(delimiterIndex + 2);

        final String? data = _extractData(frame);
        if (data == null || data == '[DONE]') {
          yield utf8.encode('$frame\n\n');
        } else {
          final dynamic decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            final Map<String, dynamic> rewritten =
                _rewriteStreamChunk(decoded, stateByChoice);
            yield utf8.encode('data: ${jsonEncode(rewritten)}\n\n');
          } else {
            yield utf8.encode('$frame\n\n');
          }
        }

        delimiterIndex = current.indexOf('\n\n');
      }

      buffer
        ..clear()
        ..write(current);
    }

    final String remaining = buffer.toString().trim();
    if (remaining.isNotEmpty) {
      final String? data = _extractData(remaining);
      if (data == null || data == '[DONE]') {
        yield utf8.encode('$remaining\n\n');
      } else {
        final dynamic decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          final Map<String, dynamic> rewritten =
              _rewriteStreamChunk(decoded, stateByChoice);
          yield utf8.encode('data: ${jsonEncode(rewritten)}\n\n');
        } else {
          yield utf8.encode('$remaining\n\n');
        }
      }
    }
  }

  Map<String, dynamic> _rewriteStreamChunk(
    Map<String, dynamic> json,
    Map<String, _MiniMaxStreamState> stateByChoice,
  ) {
    final dynamic choices = json['choices'];
    if (choices is! List) {
      return json;
    }

    for (final dynamic choice in choices) {
      if (choice is! Map<String, dynamic>) {
        continue;
      }

      final String choiceKey = '${choice['index'] ?? 0}';
      final _MiniMaxStreamState state = stateByChoice.putIfAbsent(
        choiceKey,
        _MiniMaxStreamState.new,
      );

      final dynamic delta = choice['delta'];
      if (delta is! Map<String, dynamic>) {
        continue;
      }

      final _ReasoningProjection projection = _projectStreamDelta(delta);
      final String currentVisible = projection.content ?? '';
      final String currentReasoning = projection.reasoningContent ?? '';

      final String newVisible = _deltaFromCumulative(
        previous: state.visibleContent,
        current: currentVisible,
      );
      final String newReasoning = _deltaFromCumulative(
        previous: state.reasoningContent,
        current: currentReasoning,
      );

      state
        ..visibleContent = currentVisible
        ..reasoningContent = currentReasoning;

      if (currentVisible.isNotEmpty || delta.containsKey('content')) {
        delta['content'] = newVisible;
      }
      if (newReasoning.isNotEmpty) {
        delta['reasoning_content'] = _mergeText(
          delta['reasoning_content'] as String?,
          newReasoning,
        );
      }
      delta.remove('reasoning_details');
    }

    return json;
  }

  _ReasoningProjection _projectNonStreamMessage(Map<String, dynamic> message) {
    final String? reasoningDetails =
        _flattenReasoningDetails(message['reasoning_details']);
    final dynamic rawContent = message['content'];
    final String? content = rawContent is String ? rawContent : null;

    if (reasoningDetails != null && reasoningDetails.isNotEmpty) {
      return _ReasoningProjection(
        content: content,
        reasoningContent: reasoningDetails,
      );
    }

    if (content == null || content.isEmpty) {
      return const _ReasoningProjection();
    }

    final _ParsedThinkContent parsed = _parseThinkSnapshot(content);
    if (!parsed.hasReasoning) {
      return _ReasoningProjection(content: content);
    }

    return _ReasoningProjection(
      content: parsed.visibleContent,
      reasoningContent: parsed.reasoningContent,
    );
  }

  _ReasoningProjection _projectStreamDelta(Map<String, dynamic> delta) {
    final String? reasoningDetails =
        _flattenReasoningDetails(delta['reasoning_details']);
    final dynamic rawContent = delta['content'];
    final String? content = rawContent is String ? rawContent : null;

    if (reasoningDetails != null && reasoningDetails.isNotEmpty) {
      return _ReasoningProjection(
        content: content ?? '',
        reasoningContent: reasoningDetails,
      );
    }

    final String? existingReasoning = delta['reasoning_content'] as String?;
    if (existingReasoning != null && existingReasoning.isNotEmpty) {
      return _ReasoningProjection(
        content: content ?? '',
        reasoningContent: existingReasoning,
      );
    }

    if (content == null || content.isEmpty) {
      return const _ReasoningProjection();
    }

    final _ParsedThinkContent parsed = _parseThinkSnapshot(content);
    if (!parsed.hasReasoning) {
      return _ReasoningProjection(content: content);
    }

    return _ReasoningProjection(
      content: parsed.visibleContent,
      reasoningContent: parsed.reasoningContent,
    );
  }

  _ParsedThinkContent _parseThinkSnapshot(String input) {
    const String openTag = '<think>';
    const String closeTag = '</think>';

    final StringBuffer visible = StringBuffer();
    final StringBuffer reasoning = StringBuffer();
    String remaining = input;
    bool insideThink = false;

    while (remaining.isNotEmpty) {
      if (!insideThink) {
        final int openIndex = remaining.indexOf(openTag);
        if (openIndex == -1) {
          visible.write(_trimTrailingPartialTag(remaining, openTag));
          break;
        }

        visible.write(remaining.substring(0, openIndex));
        remaining = remaining.substring(openIndex + openTag.length);
        insideThink = true;
      } else {
        final int closeIndex = remaining.indexOf(closeTag);
        if (closeIndex == -1) {
          reasoning.write(_trimTrailingPartialTag(remaining, closeTag));
          break;
        }

        reasoning.write(remaining.substring(0, closeIndex));
        remaining = remaining.substring(closeIndex + closeTag.length);
        insideThink = false;
      }
    }

    return _ParsedThinkContent(
      visibleContent: visible.toString(),
      reasoningContent: reasoning.toString(),
    );
  }

  String _trimTrailingPartialTag(String value, String tag) {
    for (int i = tag.length - 1; i > 0; i--) {
      final String suffix =
          value.length >= i ? value.substring(value.length - i) : value;
      if (tag.startsWith(suffix)) {
        return value.substring(0, value.length - suffix.length);
      }
    }
    return value;
  }

  String? _flattenReasoningDetails(dynamic raw) {
    if (raw == null) {
      return null;
    }
    if (raw is String && raw.isNotEmpty) {
      return raw;
    }
    if (raw is List) {
      final List<String> parts = <String>[];
      for (final dynamic item in raw) {
        final String? text = _flattenReasoningDetails(item);
        if (text != null && text.isNotEmpty) {
          parts.add(text);
        }
      }
      if (parts.isEmpty) {
        return null;
      }
      return parts.join();
    }
    if (raw is Map<String, dynamic>) {
      final dynamic text = raw['text'] ?? raw['content'];
      if (text is String && text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  String _deltaFromCumulative({
    required String previous,
    required String current,
  }) {
    if (previous.isEmpty) {
      return current;
    }
    if (current.startsWith(previous)) {
      return current.substring(previous.length);
    }
    return current;
  }

  String _mergeText(String? existing, String addition) {
    if (existing == null || existing.isEmpty) {
      return addition;
    }
    if (addition.isEmpty) {
      return existing;
    }
    return '$existing$addition';
  }

  String? _extractData(String frame) {
    final List<String> dataLines = frame
        .split('\n')
        .where((String line) => line.startsWith('data:'))
        .map((String line) => line.substring(5).trimLeft())
        .toList(growable: false);

    if (dataLines.isEmpty) {
      return null;
    }

    return dataLines.join('\n');
  }
}

class _ReasoningProjection {
  final String? content;
  final String? reasoningContent;

  const _ReasoningProjection({
    this.content,
    this.reasoningContent,
  });
}

class _ParsedThinkContent {
  final String visibleContent;
  final String reasoningContent;

  const _ParsedThinkContent({
    required this.visibleContent,
    required this.reasoningContent,
  });

  bool get hasReasoning => reasoningContent.isNotEmpty;
}

class _MiniMaxStreamState {
  String visibleContent = '';
  String reasoningContent = '';
}
