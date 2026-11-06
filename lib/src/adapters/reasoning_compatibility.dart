import 'exception.dart';

/// Normalizes the gateway's shared reasoning controls for each provider.
///
/// [reasoning_effort], [enable_thinking] and [thinking.type] are accepted as
/// equivalent inputs. Provider-native fields are emitted after resolving their
/// shared enable/disable meaning. Model-specific branches are intentionally
/// explicit so a boolean-only API never receives a misleading effort value.
class ReasoningCompatibility {
  const ReasoningCompatibility._();

  static Map<String, dynamic> apply({
    required Map<String, dynamic> body,
    required String provider,
    required String model,
  }) {
    final String normalizedProvider = provider.toLowerCase();
    final String normalizedModel = model.toLowerCase();
    final String? effort = _readEffort(body['reasoning_effort']);
    final bool hasEnableThinking = body.containsKey('enable_thinking');
    final bool? enableThinking = _readEnableThinking(body['enable_thinking']);
    final bool hasThinking = body.containsKey('thinking');
    final Map<String, dynamic>? thinking = _readThinking(body['thinking']);
    final String? thinkingType = thinking?['type'] as String?;
    if (thinkingType != null &&
        !const {'enabled', 'disabled', 'adaptive'}.contains(thinkingType)) {
      throw UnsupportedRequestException(
        '`thinking.type` must be `enabled`, `disabled`, or `adaptive`.',
      );
    }
    if (effort == null) body.remove('reasoning_effort');
    if (enableThinking == null) body.remove('enable_thinking');
    if (thinking == null) body.remove('thinking');

    final bool? providerEffortEnabled = effort == null
        ? null
        : normalizedProvider == 'doubao'
            ? effort != 'none' && effort != 'minimal'
            : effort != 'none';
    final bool? thinkingEnabled = thinkingType == null
        ? null
        : thinkingType == 'disabled'
            ? false
            : true;
    final Set<bool> requestedStates = <bool>{
      if (providerEffortEnabled != null) providerEffortEnabled,
      if (enableThinking != null) enableThinking,
      if (thinkingEnabled != null) thinkingEnabled,
    };
    if (requestedStates.length > 1) {
      throw UnsupportedRequestException(
        '`reasoning_effort`, `enable_thinking`, and `thinking.type` specify conflicting reasoning states.',
      );
    }
    if (effort != null &&
        !const {
          'none',
          'minimal',
          'low',
          'medium',
          'high',
          'xhigh',
          'max',
          // DeepSeek also accepts this documented compatibility alias.
          'ultra',
        }.contains(effort)) {
      throw UnsupportedRequestException(
        '`reasoning_effort` must be one of `none`, `minimal`, `low`, `medium`, `high`, `xhigh`, or `max`.',
      );
    }
    if (normalizedProvider == 'openai' && effort == 'ultra') {
      throw UnsupportedRequestException(
        '`ultra` is not an OpenAI `reasoning_effort` value; use `max`.',
      );
    }
    if (requestedStates.isEmpty) {
      if (normalizedProvider == 'doubao' || normalizedProvider == 'hunyuan') {
        _rejectUnsupportedThinkingKeep(
          thinking,
          normalizedProvider == 'doubao' ? 'Doubao' : 'Hunyuan',
        );
        if (thinking != null && thinkingType == null) {
          throw UnsupportedRequestException(
            '`thinking.type` is required by the ${normalizedProvider == 'doubao' ? 'Doubao' : 'Hunyuan'} adapter.',
          );
        }
      } else if (normalizedProvider == 'qwen') {
        body.remove('thinking');
        _mapThinkingKeepToQwen(body, thinking);
      } else if (thinking?.containsKey('keep') == true) {
        if (normalizedProvider == 'kimi') {
          _validateKimiThinkingKeep(thinking, normalizedModel);
        } else {
          throw UnsupportedRequestException(
            'The target model does not support `thinking.keep`.',
          );
        }
      }
      if (normalizedProvider == 'deepseek' &&
          _isForcedToolChoice(body['tool_choice'])) {
        body['reasoning_effort'] = 'none';
      }
      return body;
    }

    final bool enabled = requestedStates.single;

    switch (normalizedProvider) {
      case 'qwen':
        if (_isQwen38Max(normalizedModel) &&
            effort != null &&
            body['thinking_budget'] != null) {
          throw UnsupportedRequestException(
            'Qwen3.8 Max does not allow `reasoning_effort` and `thinking_budget` together.',
          );
        }
        if (effort == 'none') {
          body.remove('reasoning_effort');
          body.remove('enable_thinking');
          body.remove('thinking');
          body['enable_thinking'] = false;
          _mapThinkingKeepToQwen(body, thinking);
          return body;
        }
        if (_supportsQwenEffort(normalizedModel) && effort != null) {
          body.remove('enable_thinking');
          body.remove('thinking');
          body['reasoning_effort'] = _normalizeQwenEffort(effort);
        } else {
          body.remove('reasoning_effort');
          body.remove('thinking');
          body.remove('enable_thinking');
          body['enable_thinking'] = enabled;
        }
        _mapThinkingKeepToQwen(body, thinking);
        return body;
      case 'deepseek':
        _rejectUnsupportedThinkingKeep(thinking, 'DeepSeek');
        body.remove('enable_thinking');
        if (thinking == null && hasThinking) {
          body.remove('thinking');
        }
        if (thinking == null && hasEnableThinking) {
          body['thinking'] = <String, dynamic>{
            'type': enabled ? 'enabled' : 'disabled',
          };
        } else if (thinking != null && thinkingType == null) {
          body['thinking'] = thinking;
        } else if (thinking != null && thinkingType == 'adaptive') {
          body['thinking'] = <String, dynamic>{
            ...thinking,
            'type': 'enabled',
          };
        }
        if (effort != null && !_supportsDeepSeekEffort(normalizedModel)) {
          body.remove('reasoning_effort');
          if (thinking == null) {
            body['thinking'] = <String, dynamic>{
              'type': enabled ? 'enabled' : 'disabled',
            };
          }
        }
        if (enabled && _isForcedToolChoice(body['tool_choice'])) {
          throw UnsupportedRequestException(
            'DeepSeek thinking mode does not support required or named tool choices; set reasoning_effort to `none` to force a tool.',
          );
        }
        return body;
      case 'glm':
        _rejectUnsupportedThinkingKeep(thinking, 'GLM');
        body.remove('enable_thinking');
        if (_supportsGlmEffort(normalizedModel)) {
          if (thinkingType == 'adaptive') {
            body['thinking'] = <String, dynamic>{
              ...?thinking,
              'type': 'enabled',
            };
          }
          if (_isGlm53(normalizedModel)) {
            if (!enabled) {
              throw UnsupportedRequestException(
                'Model `$model` requires thinking to stay enabled.',
              );
            }
            if (effort != null) {
              body['reasoning_effort'] = _normalizeGlm53Effort(effort);
              if (thinking == null && hasThinking) body.remove('thinking');
            }
            return body;
          }
          if (effort != null) {
            body['reasoning_effort'] = _normalizeGlm52Effort(effort);
          } else if (!enabled) {
            body['reasoning_effort'] = 'none';
          }
          return body;
        }
        body.remove('reasoning_effort');
        if (thinking == null) {
          body['thinking'] = <String, dynamic>{
            'type': enabled ? 'enabled' : 'disabled',
          };
        } else if (thinkingType == 'adaptive') {
          body['thinking'] = <String, dynamic>{
            ...thinking,
            'type': 'enabled',
          };
        }
        return body;
      case 'kimi':
        body.remove('enable_thinking');
        if (_supportsKimiEffort(normalizedModel)) {
          if (!enabled) {
            throw UnsupportedRequestException(
              'Model `$model` always thinks and does not support disabling reasoning.',
            );
          }
          if (effort != null) {
            body['reasoning_effort'] = _normalizeKimiEffort(effort);
          }
          body.remove('thinking');
          return body;
        }
        _validateKimiThinkingKeep(thinking, normalizedModel);
        if (_isKimiAlwaysThinking(normalizedModel) && !enabled) {
          throw UnsupportedRequestException(
            'Model `$model` always uses thinking and cannot disable it.',
          );
        }
        body.remove('reasoning_effort');
        if (!_isKimiAlwaysThinking(normalizedModel)) {
          body['thinking'] = <String, dynamic>{
            ...?thinking,
            'type': enabled ? 'enabled' : 'disabled',
          };
        }
        return body;
      case 'minimax':
        _rejectUnsupportedThinkingKeep(thinking, 'MiniMax');
        body.remove('enable_thinking');
        if (_isMiniMaxM31Flash(normalizedModel)) {
          if (!enabled) {
            throw UnsupportedRequestException(
              'Model `$model` does not support disabling thinking.',
            );
          }
          body.remove('thinking');
          if (effort != null) {
            body['reasoning_effort'] = _normalizeMiniMaxEffort(effort);
          }
          return body;
        }
        if (_isMiniMaxM2(normalizedModel) && !enabled) {
          throw UnsupportedRequestException(
            'Model `$model` ignores thinking disable requests.',
          );
        }
        body.remove('reasoning_effort');
        if (thinking == null) {
          body['thinking'] = <String, dynamic>{
            'type': enabled ? 'adaptive' : 'disabled',
          };
        }
        return body;
      case 'mimo':
        _rejectUnsupportedThinkingKeep(thinking, 'MiMo');
        body.remove('reasoning_effort');
        body.remove('enable_thinking');
        body['thinking'] = <String, dynamic>{
          ...?thinking,
          'type': enabled ? 'enabled' : 'disabled',
        };
        return body;
      case 'doubao':
        _rejectUnsupportedThinkingKeep(thinking, 'Doubao');
        body.remove('enable_thinking');
        if (effort != null) {
          body['reasoning_effort'] = _normalizeDoubaoEffort(
            normalizedModel,
            effort,
          );
        }
        if (enableThinking != null && thinking == null) {
          body['thinking'] = <String, dynamic>{
            'type': enabled ? 'enabled' : 'disabled',
          };
        }
        if (thinkingType == 'adaptive') {
          body['thinking'] = <String, dynamic>{
            ...?thinking,
            'type': 'enabled',
          };
        }
        return body;
      case 'hunyuan':
        _rejectUnsupportedThinkingKeep(thinking, 'Hunyuan');
        body.remove('enable_thinking');
        if (effort != null) {
          final String nativeEffort =
              _normalizeHunyuanEffort(normalizedModel, effort);
          body['reasoning_effort'] = nativeEffort;
          body['thinking'] = <String, dynamic>{
            ...?thinking,
            'type': nativeEffort == 'none' ? 'disabled' : 'enabled',
          };
        } else if (thinking == null) {
          body['thinking'] = <String, dynamic>{
            'type': enabled ? 'enabled' : 'disabled',
          };
        } else if (thinkingType == 'adaptive') {
          body['thinking'] = <String, dynamic>{
            ...thinking,
            'type': 'enabled',
          };
        }
        return body;
      case 'openai':
        body.remove('enable_thinking');
        body.remove('thinking');
        if (!_supportsOpenAiReasoning(normalizedModel)) {
          if (effort != null && !hasEnableThinking && !hasThinking) {
            return body;
          }
          // A model without a reasoning switch cannot be asked to think, so a
          // request that only turns thinking off is already satisfied. The
          // aliases were removed above; do not fail the whole request for it.
          if (!enabled) {
            return body;
          }
          throw UnsupportedRequestException(
            'Model `$model` does not expose a compatible reasoning control.',
          );
        }
        if (!enabled && _isOpenAiNoneUnsupported(normalizedModel)) {
          throw UnsupportedRequestException(
            'Model `$model` does not support `reasoning_effort: none`.',
          );
        }
        if (effort == 'minimal' && normalizedModel.contains('gpt-6.1-sol')) {
          throw UnsupportedRequestException(
            'Model `$model` does not support `reasoning_effort: minimal`.',
          );
        }
        if (!enabled) {
          body['reasoning_effort'] = 'none';
        } else if (effort != null) {
          body['reasoning_effort'] = effort;
        }
        return body;
      default:
        return body;
    }
  }

  static String? _readEffort(dynamic value) {
    if (value == null) return null;
    if (value is! String || value.isEmpty) {
      throw UnsupportedRequestException('`reasoning_effort` must be a string.');
    }
    return value.toLowerCase();
  }

  static bool? _readEnableThinking(dynamic value) {
    if (value == null) return null;
    if (value is! bool) {
      throw UnsupportedRequestException('`enable_thinking` must be a boolean.');
    }
    return value;
  }

  static Map<String, dynamic>? _readThinking(dynamic value) {
    if (value == null) return null;
    if (value is! Map) {
      throw UnsupportedRequestException('`thinking` must be an object.');
    }
    final Map<String, dynamic> result = Map<String, dynamic>.from(value);
    if (result['type'] != null && result['type'] is! String) {
      throw UnsupportedRequestException('`thinking.type` must be a string.');
    }
    return result;
  }

  static void _mapThinkingKeepToQwen(
    Map<String, dynamic> body,
    Map<String, dynamic>? thinking,
  ) {
    if (thinking == null || !thinking.containsKey('keep')) return;
    final dynamic keep = thinking['keep'];
    if (keep != null && keep != 'all') {
      throw UnsupportedRequestException(
        'Qwen only supports `thinking.keep: all`.',
      );
    }
    body['preserve_thinking'] = keep == 'all';
  }

  static void _rejectUnsupportedThinkingKeep(
    Map<String, dynamic>? thinking,
    String provider,
  ) {
    if (thinking?.containsKey('keep') == true) {
      throw UnsupportedRequestException(
        '$provider does not support the `thinking.keep` option.',
      );
    }
  }

  static void _validateKimiThinkingKeep(
    Map<String, dynamic>? thinking,
    String model,
  ) {
    if (thinking?.containsKey('keep') != true) return;
    if (!model.contains('k2.6') && !model.contains('k2.7-code')) {
      throw UnsupportedRequestException(
        'Model `$model` does not support `thinking.keep`.',
      );
    }
    final dynamic keep = thinking!['keep'];
    if (keep != null && keep != 'all') {
      throw UnsupportedRequestException(
        'Kimi only supports `thinking.keep: all`.',
      );
    }
  }

  static bool _supportsQwenEffort(String model) =>
      RegExp(r'^qwen3\.8-(?:max|flash|omni-flash)(?:-|$)').hasMatch(model);

  static bool _isQwen38Max(String model) =>
      RegExp(r'^qwen3\.8-max(?:-|$)').hasMatch(model);

  static String _normalizeQwenEffort(String effort) => switch (effort) {
        'minimal' => 'low',
        'medium' => 'medium',
        'high' || 'xhigh' || 'max' || 'ultra' => 'xhigh',
        _ => effort,
      };

  static bool _isForcedToolChoice(dynamic value) =>
      value == 'required' ||
      value is Map && value['type'] == 'function' && value['function'] is Map;

  static bool _supportsDeepSeekEffort(String model) =>
      model.startsWith('deepseek-v4') || model == 'deepseek-flash';

  static bool _supportsGlmEffort(String model) {
    final RegExpMatch? version =
        RegExp(r'glm-(\d+(?:\.\d+)?)').firstMatch(model);
    if (version == null) return false;
    final double? value = double.tryParse(version.group(1)!);
    return value != null && value >= 5.2;
  }

  static bool _isGlm53(String model) => model.contains('glm-5.3');

  static String _normalizeGlm52Effort(String effort) => switch (effort) {
        'minimal' => 'none',
        'low' || 'medium' => 'high',
        'xhigh' || 'ultra' => 'max',
        _ => effort,
      };

  static String _normalizeGlm53Effort(String effort) => switch (effort) {
        'minimal' || 'low' => 'low',
        'medium' || 'high' => 'high',
        'xhigh' || 'max' || 'ultra' => 'max',
        _ => effort,
      };

  static bool _supportsKimiEffort(String model) =>
      model.startsWith('kimi-k3') && !model.contains('code');

  static String _normalizeKimiEffort(String effort) => switch (effort) {
        'minimal' || 'low' => 'low',
        'medium' || 'high' => 'high',
        'xhigh' || 'max' || 'ultra' => 'max',
        'none' => throw UnsupportedRequestException(
            'Kimi K3 does not support disabling reasoning.',
          ),
        _ => effort,
      };

  static bool _isKimiAlwaysThinking(String model) =>
      model.contains('k2.7-code') || model.contains('k2.7-code-highspeed');

  static bool _isMiniMaxM31Flash(String model) => model.contains('m3.1-flash');

  static String _normalizeMiniMaxEffort(String effort) => switch (effort) {
        'minimal' || 'low' => 'low',
        'medium' => 'medium',
        'high' => 'high',
        'xhigh' => 'xhigh',
        'max' || 'ultra' => 'max',
        'none' => throw UnsupportedRequestException(
            'MiniMax M3.1-Flash does not support `reasoning_effort: none`.',
          ),
        _ => effort,
      };

  static String _normalizeDoubaoEffort(String model, String effort) {
    if (!_supportsDoubaoEffort(model)) return effort;
    return switch (effort) {
      // Ark treats minimal as a direct answer and accepts it as the
      // compatibility value for none on the current Seed reasoning models.
      'none' || 'minimal' => 'minimal',
      'xhigh' || 'max' || 'ultra' => 'high',
      _ => effort,
    };
  }

  static bool _supportsDoubaoEffort(String model) =>
      model.startsWith('doubao-seed-') ||
      model.startsWith('doubao-seed-evolving');

  static String _normalizeHunyuanEffort(String model, String effort) {
    final bool isHy4 = model.startsWith('hy4-preview');
    final bool isHy3 = model.startsWith('hy3');
    if (!isHy3 && !isHy4) return effort;

    return switch (effort) {
      'none' => 'none',
      'minimal' || 'low' => isHy3 ? 'low' : 'high',
      'medium' || 'high' || 'xhigh' || 'max' || 'ultra' => 'high',
      _ => effort,
    };
  }

  static bool _isMiniMaxM2(String model) =>
      RegExp(r'minimax-m2(?:\.|$)').hasMatch(model);

  static bool _supportsOpenAiReasoning(String model) =>
      RegExp(r'^(o[134](?:-|$)|gpt-(?:5|6)(?:\.|-|$))').hasMatch(model);

  static bool _isOpenAiNoneUnsupported(String model) =>
      model.contains('gpt-6.1-sol') || model.contains('gpt-6-astra');
}
