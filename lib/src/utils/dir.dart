import 'dart:io';

class Dir {
  static String? _executableDir;

  static executableDir() {
    if(_executableDir == null) {
      String scriptPath;
      if (Platform.script.scheme == 'file') {
        scriptPath = "${Directory.current.path}${Platform.pathSeparator}bin";
        _executableDir = scriptPath;
      } else {
        scriptPath = Platform.resolvedExecutable;
        _executableDir = File(scriptPath).parent.path;
      }
      return _executableDir;
    }
    return _executableDir;
  }

  /// user writable log directory
  ///
  /// priority:
  /// 1. LOG_DIR environment variable
  /// 2. HOME / USERPROFILE -> $home/.agentos/log/lite_oneapi
  /// 3. Windows: LOCALAPPDATA -> $LOCALAPPDATA/AgentOS/log/lite_oneapi
  /// 4. Windows: APPDATA -> $APPDATA/AgentOS/log/lite_oneapi
  /// 5. Fallback: systemTemp/agentos/log/lite_oneapi
  static String resolveLogDir() {
    final envLogDir = Platform.environment['LOG_DIR'];
    if (envLogDir != null && envLogDir.isNotEmpty) {
      return envLogDir;
    }

    final sep = Platform.pathSeparator;

    final homeDir =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (homeDir != null && homeDir.isNotEmpty) {
      return '$homeDir${sep}.agentos${sep}log${sep}lite_oneapi';
    }

    if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null && localAppData.isNotEmpty) {
        return '$localAppData${sep}AgentOS${sep}log${sep}lite_oneapi';
      }
      final appData = Platform.environment['APPDATA'];
      if (appData != null && appData.isNotEmpty) {
        return '$appData${sep}AgentOS${sep}log${sep}lite_oneapi';
      }
    }

    return '${Directory.systemTemp.path}${sep}agentos${sep}log${sep}lite_oneapi';
  }
}