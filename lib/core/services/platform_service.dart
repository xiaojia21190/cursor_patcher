import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class PlatformService {
  Future<String> getStoragePath() async {
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      return path.join(appData!, 'Cursor', 'User', 'globalStorage', 'storage.json');
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      return path.join(home!, 'Library', 'Application Support', 'Cursor', 'User', 'globalStorage', 'storage.json');
    } else if (Platform.isLinux) {
      final home = Platform.environment['HOME'];
      return path.join(home!, '.config', 'Cursor', 'User', 'globalStorage', 'storage.json');
    }
    throw UnsupportedError('Unsupported platform');
  }

  Future<String> getDbPath() async {
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      return path.join(appData!, 'Cursor', 'User', 'globalStorage', 'state.vscdb');
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      return path.join(home!, 'Library', 'Application Support', 'Cursor', 'User', 'globalStorage', 'state.vscdb');
    } else if (Platform.isLinux) {
      final home = Platform.environment['HOME'];
      return path.join(home!, '.config', 'Cursor', 'User', 'globalStorage', 'state.vscdb');
    }
    throw UnsupportedError('Unsupported platform');
  }

  Future<(String, String)> getCursorAppPaths() async {
    if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      final basePath = path.join(localAppData!, 'Programs', 'Cursor', 'resources', 'app');
      return (path.join(basePath, 'package.json'), path.join(basePath, 'out', 'main.js'));
    } else if (Platform.isMacOS) {
      const basePath = '/Applications/Cursor.app/Contents/Resources/app';
      return (path.join(basePath, 'package.json'), path.join(basePath, 'out', 'main.js'));
    } else if (Platform.isLinux) {
      const possiblePaths = ['/opt/Cursor/resources/app', '/usr/share/cursor/resources/app'];

      for (final basePath in possiblePaths) {
        if (Directory(basePath).existsSync()) {
          return (path.join(basePath, 'package.json'), path.join(basePath, 'out', 'main.js'));
        }
      }
      throw Exception('Cursor installation not found on Linux');
    }
    throw UnsupportedError('Unsupported platform');
  }
}
