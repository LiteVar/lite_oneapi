class RequestCompatibilityPatch {
  const RequestCompatibilityPatch._();

  static Map<String, dynamic> applyReasoningContentReplayPatch(
    Map<String, dynamic> requestBody,
  ) {
    final String? model = requestBody['model'] as String?;
    if (model == null || !requiresReasoningContentReplay(model)) {
      return requestBody;
    }

    final dynamic messages = requestBody['messages'];
    if (messages is! List) {
      return requestBody;
    }

    for (final dynamic message in messages) {
      if (message is! Map<String, dynamic>) {
        continue;
      }

      if (!_isAssistantToolCallMessage(message)) {
        continue;
      }

      final dynamic reasoningContent = message['reasoning_content'];
      if (reasoningContent is String && reasoningContent.isNotEmpty) {
        continue;
      }

      message.putIfAbsent('reasoning_content', () => '');
      if (message['reasoning_content'] == null) {
        message['reasoning_content'] = '';
      }
    }

    return requestBody;
  }

  static bool requiresReasoningContentReplay(String model) {
    return _isDeepSeekReasoningReplayModel(model) || _isMimoReasoningReplayModel(model);
  }

  static bool _isDeepSeekReasoningReplayModel(String model) {
    final List<int>? version = _extractModelVersion(model, family: 'deepseek-v');
    if (version == null) {
      return false;
    }
    return _compareVersion(version, const <int>[4]) >= 0;
  }

  static bool _isMimoReasoningReplayModel(String model) {
    final List<int>? version = _extractModelVersion(model, family: 'mimo-v');
    if (version == null) {
      return false;
    }
    return _compareVersion(version, const <int>[2, 5]) >= 0;
  }

  static bool _isAssistantToolCallMessage(Map<String, dynamic> message) {
    if (message['role'] != 'assistant') {
      return false;
    }

    final dynamic toolCalls = message['tool_calls'];
    return toolCalls is List && toolCalls.isNotEmpty;
  }

  static List<int>? _extractModelVersion(String model, {required String family}) {
    final String normalized = model.toLowerCase();
    if (!normalized.startsWith(family)) {
      return null;
    }

    final String suffix = normalized.substring(family.length);
    final RegExpMatch? match = RegExp(r'^(\d+)(?:\.(\d+))?').firstMatch(suffix);
    if (match == null) {
      return null;
    }

    final List<int> version = <int>[];
    for (int groupIndex = 1; groupIndex <= match.groupCount; groupIndex++) {
      final String? part = match.group(groupIndex);
      if (part != null) {
        version.add(int.parse(part));
      }
    }
    return version;
  }

  static int _compareVersion(List<int> left, List<int> right) {
    final int maxLength = left.length > right.length ? left.length : right.length;
    for (int index = 0; index < maxLength; index++) {
      final int leftPart = index < left.length ? left[index] : 0;
      final int rightPart = index < right.length ? right[index] : 0;
      if (leftPart != rightPart) {
        return leftPart.compareTo(rightPart);
      }
    }
    return 0;
  }
}
