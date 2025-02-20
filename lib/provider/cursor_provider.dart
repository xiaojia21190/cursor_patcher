import 'dart:convert';
import 'dart:io';
import 'package:cusor_patcher/model/token_data.dart';
import 'package:path/path.dart' as path;

import 'package:cusor_patcher/utils/constants.dart';
import 'package:cusor_patcher/model/cursor_helper.dart';
import 'package:cusor_patcher/provider/persistence_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:logger/logger.dart';

part 'cursor_provider.g.dart';

@riverpod
class Cursor extends _$Cursor {
  List<String> stdOut = [];
  Logger logger = Logger();
  late PersistenceService _persistenceService;

  @override
  CursorHelper build() {
    _persistenceService = ref.watch(persistenceProvider);
    // 内部获得
    return CursorHelper(
      token: _persistenceService.getToken(),
    );
  }

  Future<void> replaceAuthToken() async {
    state = state.copyWith(token: "");
  }

  Future<CursorHelper> getCursorHelper({defaultToken}) async {
    final token = defaultToken ?? ref.read(persistenceProvider).getToken();
    final response = await http.get(Uri.parse('https://cursor.ccopilot.org/api/users/get_auth_code.php'), headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonData['data'] == null) {
        throw Exception('Failed to get cursor helper');
      }
      final helper = CursorHelper.fromJson(jsonData['data']);
      state = state.copyWith(authCode: helper.authCode, maxDailyLimit: helper.maxDailyLimit, todayRemaining: helper.todayRemaining, totalUsed: helper.totalUsed);
      return helper;
    } else {
      throw Exception('Failed to get cursor helper');
    }
  }

  //刷新激活码
  Future<void> refreshAuthCode() async {
    final helper = await getCursorHelper();
    debugPrint(helper.toString());
    state = state.copyWith(authCode: helper.authCode, maxDailyLimit: helper.maxDailyLimit, todayRemaining: helper.todayRemaining, totalUsed: helper.totalUsed);
  }

  //重置激活码
  Future<void> resetAuthCode() async {
    final token = ref.read(persistenceProvider).getToken();
    final response = await http.get(Uri.parse('https://cursor.ccopilot.org/api/users/reset_auth_code.php'), headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      String authCode = jsonData["data"]['auth_code'];
      state = state.copyWith(authCode: authCode);
    } else {
      //显示错误
      throw Exception('Failed to reset auth code');
    }
  }

  Future<void> replaceToken(String authCode) async {
    try {
      debugPrint('提示：本脚本请不要再 Cursor 中执行');
      addOutput("提示：本脚本请不要再 Cursor 中执");
      final cursorAppPaths = await getCursorAppPaths();
      final filesExist = await checkFilesExist(cursorAppPaths.$1, cursorAppPaths.$2);
      if (!filesExist) {
        debugPrint('请检查是否正确安装 Cursor');
        addOutput("请检查是否正确安装 Cursor");
        throw Exception('请检查是否正确安装 Cursor');
      } else {
        final packageJson = jsonDecode(File(cursorAppPaths.$1).readAsStringSync()) as Map<String, dynamic>;
        final currentVersion = packageJson["version"];
        debugPrint('当前 Cursor 版本: $currentVersion');
        addOutput('当前 Cursor 版本: $currentVersion');

        debugPrint("开始退出 Cursor..");
        addOutput("开始退出 Cursor..");
        final exitCursorResult = await exitCursor();
        if (!exitCursorResult) {
          debugPrint("退出 Cursor 失败");
          addOutput("退出 Cursor 失败");
          throw Exception('退出 Cursor 失败');
        }
        debugPrint("所有 Cursor 进程已正常关闭");
        addOutput("所有 Cursor 进程已正常关闭");

        final needPatch = await checkVersion(currentVersion, minVersion: AppConstants.minPatchVersion);
        if (!needPatch) {
          debugPrint('当前版本无需 Patch，继续执行 Token 更新...');
          addOutput('当前版本无需 Patch，继续执行 Token 更新...');
        } else {
          debugPrint("开始 Patch Cursor 机器码..");
          addOutput("开始 Patch Cursor 机器码..");
          final patchMainJsResult = await patchMainJs(cursorAppPaths.$2);
          if (patchMainJsResult) {
            debugPrint("Cursor 机器码已成功 Patch");
            addOutput("Cursor 机器码已成功 Patch");
          }
        }
        final tokenData = await fetchTokenData(currentVersion, authCode);
        debugPrint('即将退出 Cursor 并修改配置，请确保所有工作已保存。');
        addOutput('即将退出 Cursor 并修改配置，请确保所有工作已保存。');

        debugPrint("开始替换 Token..");
        addOutput("开始替换 Token..");
        final resetCursorIdResult = await resetCursorId(tokenData);
        if (resetCursorIdResult) {
          debugPrint("Cursor 机器码已成功修改");
          addOutput("Cursor 机器码已成功修改");
          await updateAuth(email: tokenData.email, accessToken: tokenData.token);
          debugPrint("成功更新 Cursor 认证信息! 邮箱: ${tokenData.email}");
          addOutput("成功更新 Cursor 认证信息! 邮箱: ${tokenData.email}");
          debugPrint("所有操作已完成，现在可以重新打开Cursor体验了");
          addOutput("所有操作已完成，现在可以重新打开Cursor体验了");
          debugPrint("请注意：建议禁用 Cursor 自动更新!!!");
          addOutput("请注意：建议禁用 Cursor 自动更新!!!");
          debugPrint("从 0.45.xx 开始每次更新都需要重新执行此脚本");
          addOutput("从 0.45.xx 开始每次更新都需要重新执行此脚本");
        }
      }
    } catch (e) {
      throw Exception('Failed to replace token');
    }
  }

  Future<bool> exitCursor() async {
    final List<String> cursorProcessNames = ['cursor', 'Cursor'];
    List<ProcessResult> processes = [];

    try {
      if (Platform.isWindows) {
        processes = await _getWindowsProcesses(cursorProcessNames);
      } else {
        processes = await _getUnixProcesses(cursorProcessNames);
      }

      if (processes.isEmpty) {
        debugPrint("未发现运行中的 Cursor 进程");
        return true;
      }

      // 终止进程
      for (var process in processes) {
        try {
          if (Platform.isWindows) {
            await Process.run('taskkill', ['/PID', process.pid.toString(), '/F']);
          } else {
            await Process.run('kill', [process.pid.toString()]);
          }
        } catch (e) {
          debugPrint('终止进程失败: ${e.toString()}');
          continue;
        }
      }

      // 等待进程终止
      final startTime = DateTime.now();
      const timeout = Duration(seconds: 10);

      while (DateTime.now().difference(startTime) < timeout) {
        final stillRunning = await _checkRunningProcesses(processes);
        if (stillRunning.isEmpty) {
          debugPrint("所有 Cursor 进程已正常关闭");
          return true;
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final stillRunning = await _checkRunningProcesses(processes);
      if (stillRunning.isNotEmpty) {
        final processList = stillRunning.map((p) => p.pid.toString()).join(', ');
        debugPrint("以下进程未能在规定时间内关闭: $processList");
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('退出Cursor时发生错误: ${e.toString()}');
      return false;
    }
  }

  Future<List<ProcessResult>> _getWindowsProcesses(List<String> processNames) async {
    final result = await Process.run('tasklist', ['/FO', 'CSV', '/NH']);
    final processes = result.stdout
        .toString()
        .split('\n')
        .where((line) => processNames.any((name) => line.toLowerCase().contains(name.toLowerCase())))
        .map((line) {
          final parts = line.split(',');
          if (parts.length >= 2) {
            final pid = int.tryParse(parts[1].replaceAll('"', '').trim());
            return ProcessResult(pid ?? 0, 0, '', '');
          }
          return null;
        })
        .whereType<ProcessResult>()
        .toList();
    return processes;
  }

  Future<List<ProcessResult>> _getUnixProcesses(List<String> processNames) async {
    final result = await Process.run('ps', ['aux']);
    final processes = result.stdout
        .toString()
        .split('\n')
        .where((line) => processNames.any((name) => line.toLowerCase().contains(name.toLowerCase())))
        .map((line) {
          final parts = line.split(RegExp(r'\s+'));
          if (parts.length >= 2) {
            final pid = int.tryParse(parts[1]);
            return ProcessResult(pid ?? 0, 0, '', '');
          }
          return null;
        })
        .whereType<ProcessResult>()
        .toList();
    return processes;
  }

  Future<List<ProcessResult>> _checkRunningProcesses(List<ProcessResult> processes) async {
    final stillRunning = <ProcessResult>[];
    for (var process in processes) {
      try {
        if (Platform.isWindows) {
          final result = await Process.run('tasklist', ['/FI', 'PID eq ${process.pid}']);
          if (result.stdout.toString().contains(process.pid.toString())) {
            stillRunning.add(process);
          }
        } else {
          final result = await Process.run('ps', ['-p', process.pid.toString()]);
          if (result.exitCode == 0) {
            stillRunning.add(process);
          }
        }
      } catch (e) {
        continue;
      }
    }
    return stillRunning;
  }

  //get_cursor_app_paths
  Future<(String, String)> getCursorAppPaths() async {
    String basePath = '';
    if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      basePath = path.join(localAppData!, 'Programs', 'Cursor', 'resources', 'app');
    } else if (Platform.isMacOS) {
      basePath = '/Applications/Cursor.app/Contents/Resources/app';
    } else if (Platform.isLinux) {
      const possiblePaths = ['/opt/Cursor/resources/app', '/usr/share/cursor/resources/app'];

      for (final p in possiblePaths) {
        if (Directory(p).existsSync()) {
          basePath = p;
        }
      }
      throw Exception('未找到Cursor安装路径');
    }
    return ('$basePath/package.json', '$basePath/out/main.js');
  }

  //check_files_exist
  Future<bool> checkFilesExist(String packageJsonPath, String mainJsPath) async {
    return File(packageJsonPath).existsSync() && File(mainJsPath).existsSync();
  }

  Future<bool> checkVersion(String version, {String? minVersion, String? maxVersion}) async {
    // 版本号格式检查 (x.x.x)
    final versionPattern = RegExp(r'^\d+\.\d+\.\d+$');
    if (!versionPattern.hasMatch(version)) {
      debugPrint('无效的版本号格式: $version');
      return false;
    }

    // 解析版本号为数字列表
    List<int> parseVersion(String ver) {
      return ver.split('.').map(int.parse).toList();
    }

    final current = parseVersion(version);

    if (minVersion != null) {
      final minVer = parseVersion(minVersion);
      if (_compareVersions(current, minVer) < 0) return false;
    }

    if (maxVersion != null) {
      final maxVer = parseVersion(maxVersion);
      if (_compareVersions(current, maxVer) > 0) return false;
    }

    return true;
  }

  int _compareVersions(List<int> v1, List<int> v2) {
    for (var i = 0; i < v1.length; i++) {
      if (v1[i] > v2[i]) return 1;
      if (v1[i] < v2[i]) return -1;
    }
    return 0;
  }

  //获得auth token
  Future<TokenData> fetchTokenData(String currentVersion, String authCode) async {
    debugPrint('正在获取 Token 数据...');
    addOutput('正在获取 Token 数据...');
    final response = await http.get(
        Uri.parse(AppConstants.apiUrl).replace(queryParameters: {
          'accessCode': authCode,
          'cursorVersion': currentVersion,
          'scriptVersion': AppConstants.scriptVersion,
        }),
        headers: {"user-agent": "python-requests"});
    if (response.statusCode == 200) {
      debugPrint('成功获取 Token 数据');
      addOutput('成功获取 Token 数据');
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return TokenData.fromJson(jsonData["data"]);
    } else {
      throw Exception('Failed to get token data');
    }
  }

  Future<bool> resetCursorId(TokenData tokenData) async {
    try {
      final storagePath = await getStoragePath();
      final file = File(storagePath);

      if (!file.existsSync()) {
        debugPrint('未找到文件: $storagePath');
        addOutput('未找到文件: $storagePath');
        return false;
      }

      // 修改文件权限为可写
      await makeFileWritable(storagePath);

      // 读取并更新数据
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      data.addAll({
        'telemetry.macMachineId': tokenData.macMachineId,
        'telemetry.machineId': tokenData.machineId,
        'telemetry.devDeviceId': tokenData.devDeviceId,
      });

      // 写入更新后的数据
      await file.writeAsString(jsonEncode(data), flush: true);

      // 恢复文件权限为只读
      await makeFileReadonly(storagePath);

      debugPrint('Cursor 机器码已成功修改');
      addOutput('Cursor 机器码已成功修改');
      return true;
    } catch (e) {
      debugPrint('重置 Cursor 机器码时发生错误: ${e.toString()}');
      addOutput('重置 Cursor 机器码时发生错误: ${e.toString()}');
      return false;
    }
  }

  Future<String> getStoragePath() async {
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      return path.join(appData!, 'cursor', 'User', 'globalStorage', 'storage.json');
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      return path.join(home!, 'Library', 'Application Support', 'cursor', 'User', 'globalStorage', 'storage.json');
    } else {
      final home = Platform.environment['HOME'];
      return path.join(home!, '.config', 'cursor', 'User', 'globalStorage', 'storage.json');
    }
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
    } else {
      throw Exception('不支持的操作系统');
    }
  }

  Future<bool> updateAuth({
    String? email,
    String? accessToken,
    String? refreshToken,
  }) async {
    final List<(String, String)> updates = [];

    if (email != null) {
      updates.add(('email', email));
    }
    if (accessToken != null) {
      updates.add(('access_token', accessToken));
    }
    if (refreshToken != null) {
      updates.add(('refresh_token', refreshToken));
    }

    if (updates.isEmpty) {
      debugPrint("没有提供任何要更新的值");
      return false;
    }

    try {
      final dbPath = await getDbPath();
      final db = sqlite3.open(dbPath);

      try {
        for (var (key, value) in updates) {
          final result = db.select(
            'SELECT 1 FROM itemTable WHERE key = ?',
            [key],
          );
          final exists = result.isNotEmpty;

          if (exists) {
            db.execute(
              'UPDATE itemTable SET value = ? WHERE key = ?',
              [value, key],
            );
          } else {
            db.execute(
              'INSERT INTO itemTable (key, value) VALUES (?, ?)',
              [key, value],
            );
          }
          debugPrint("成功${exists ? '更新' : '插入'} ${key.split('/').last}");
          addOutput("成功${exists ? '更新' : '插入'} ${key.split('/').last}");
        }
        return true;
      } finally {
        db.dispose();
      }
    } catch (e) {
      debugPrint("数据库错误: ${e.toString()}");
      addOutput("数据库错误: ${e.toString()}");
      return false;
    }
  }

  Future<bool> patchMainJs(String mainPath) async {
    try {
      // 读取文件内容
      final file = File(mainPath);
      String content = await file.readAsString();

      // 定义需要替换的模式
      final patterns = {RegExp(r'async getMachineId\(\)\{return [^??]+\?\?([^}]+)\}'): (Match m) => 'async getMachineId(){return ${m[1]}}', RegExp(r'async getMacMachineId\(\)\{return [^??]+\?\?([^}]+)\}'): (Match m) => 'async getMacMachineId(){return ${m[1]}}'};

      // 检查是否存在需要修复的代码
      bool foundPatterns = false;
      for (final pattern in patterns.keys) {
        if (pattern.hasMatch(content)) {
          foundPatterns = true;
          break;
        }
      }

      if (!foundPatterns) {
        debugPrint('未发现需要修复的代码，可能已经修复或不支持当前版本');
        addOutput('未发现需要修复的代码，可能已经修复或不支持当前版本');
        return true;
      }

      // 执行替换
      for (final entry in patterns.entries) {
        content = content.replaceAllMapped(entry.key, entry.value);
      }

      // 修改文件权限并写入
      await makeFileWritable(mainPath);

      await file.writeAsString(content);

      await makeFileReadonly(mainPath);

      debugPrint('成功 Patch Cursor 机器码');
      addOutput('成功 Patch Cursor 机器码');
      return true;
    } catch (e) {
      debugPrint('Patch Cursor 机器码时发生错误: $e');
      addOutput('Patch Cursor 机器码时发生错误: $e');
      return false;
    }
  }

  Future<void> makeFileWritable(String filePath) async {
    if (Platform.isWindows) {
      await Process.run('attrib', ['-R', filePath]);
    } else {
      await Process.run('chmod', ['+w', filePath]);
    }
  }

  Future<void> makeFileReadonly(String filePath) async {
    if (Platform.isWindows) {
      await Process.run('attrib', ['+R', filePath]);
    } else {
      await Process.run('chmod', ['-w', filePath]);
    }
  }

  void addOutput(String text) {
    if (text.contains('\n') && text.contains('[')) {
      List<String> lines = text.split('\n');
      for (String line in lines) {
        if (line.isNotEmpty) {
          stdOut.add(line);
        }
      }
    } else {
      stdOut.add(text);
    }
    state = state.copyWith(output: stdOut);
  }

  //getVersion   https://cursor.ccopilot.org/api/version/versions.txt?v=20250209
  Future<void> getVersion() async {
    final response = await http.get(Uri.parse('https://cursor.ccopilot.org/api/version/versions.txt?v=20250209'));
    if (response.statusCode == 200) {
      state = state.copyWith(cursorVersion: response.body.split('\n'), filterCursorVersion: response.body.split('\n'));
    } else {
      throw Exception('Failed to get versions');
    }
  }

  Future<void> getFilterVersion(String searchText) async {
    if (searchText.isEmpty) {
      state = state.copyWith(filterCursorVersion: state.cursorVersion);
      return;
    }
    debugPrint(state.cursorVersion.where((version) => version.split(",")[0].toLowerCase().contains(searchText.toLowerCase())).toString());
    state = state.copyWith(filterCursorVersion: state.cursorVersion.where((version) => version.split(",")[0].toLowerCase().contains(searchText.toLowerCase())).toList());
  }
}
