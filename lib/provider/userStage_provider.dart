import 'dart:convert';
import 'dart:io';

import 'package:cusor_patcher/provider/persistence_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:cusor_patcher/model/user_stage.dart';

part 'userStage_provider.g.dart';

@riverpod
class UserStageHelper extends _$UserStageHelper {
  late PersistenceService _persistenceService;
  @override
  UserStage build() {
    _persistenceService = ref.watch(persistenceProvider);
    return UserStage();
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

  // 获取当前cursor账户的信息
  //https://www.cursor.com/api/usage?user=【userId】
  Future<void> getCursorAccountInfo() async {
    try {
      final dbPath = await getDbPath();
      final db = sqlite3.open(dbPath);

      try {
        final result = db.select(
          'SELECT * FROM itemTable WHERE key = ?',
          ['cursorAuth/cachedEmail'],
        );
        final exists = result.isNotEmpty;

        if (exists) {
          final token = _persistenceService.getToken();
          final jsonBody = jsonEncode({
            "page": "1",
            "limit": "15",
            "email": result.first['value'],
            "status": "1",
            "contributor": "",
          });
          //https://www.cursor.com/api/auth/me
          final usageResponse = await http.post(Uri.parse('https://cursor.ccopilot.org/api/get_usage.php'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonBody);
          if (usageResponse.statusCode == 200) {
            final jsonData = jsonDecode(usageResponse.body) as Map<String, dynamic>;
            final userStage = UserStage.fromJson(jsonData['data']['items'][0]);
            state = state.copyWith(totalUsed: userStage.totalUsed, totalAvailable: userStage.totalAvailable, email: userStage.email, contributor: userStage.contributor, status: userStage.status, disableReason: userStage.disableReason);
          } else {
            throw Exception('Failed to get cursor account info');
          }
        } else {
          throw Exception('Failed to get cursor account info');
        }
      } finally {
        db.dispose();
      }
    } catch (e) {
      debugPrint("数据库错误: ${e.toString()}");
    }
  }

  //找到自己的信息根据userid + token 获取
  Future<bool> getUserInfo() async {
    final userData = await ref.read(persistenceProvider).getUserData();
    if (userData?['userId'] == "") {
      return false;
    }

    try {
      final dbPath = await getDbPath();
      final db = sqlite3.open(dbPath);

      try {
        final resultToken = db.select(
          'SELECT * FROM itemTable WHERE key = ?',
          ['cursorAuth/accessToken'],
        );
        final existsToken = resultToken.isNotEmpty;

        if (existsToken) {
          //https://www.cursor.com/api/auth/me
          final resultEmail = db.select(
            'SELECT * FROM itemTable WHERE key = ?',
            ['cursorAuth/cachedEmail'],
          );
          final existsEmail = resultEmail.isNotEmpty;
          if (existsEmail) {
            final email = resultEmail.first['value'];
            final usageResponse = await http.get(Uri.parse('https://www.cursor.com/api/usage?user=${userData?["userId"]}'), headers: {
              'Cookie': 'WorkosCursorSessionToken=${userData?["userId"]}::${resultToken.first['value']}',
            });
            if (usageResponse.statusCode == 200) {
              final usageData = jsonDecode(usageResponse.body) as Map<String, dynamic>;
              state = state.copyWith(totalUsed: usageData["gpt-4"]["numRequests"], totalAvailable: usageData["gpt-4"]["maxRequestUsage"], email: email, contributor: "", status: 1, disableReason: "");
              return true;
            } else {
              throw Exception('Failed to get cursor account info');
            }
          } else {
            throw Exception('Failed to get cursor account info');
          }
        } else {
          throw Exception('Failed to get cursor account info');
        }
      } finally {
        db.dispose();
      }
    } catch (e) {
      debugPrint("数据库错误: ${e.toString()}");
    }

    return true;
  }
}
