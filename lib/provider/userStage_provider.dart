import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:cusor_patcher/model/user_stage.dart';

part 'userStage_provider.g.dart';

@riverpod
class UserStageHelper extends _$UserStageHelper {
  @override
  Future<UserStage> build() async {
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
  Future<UserStage> getCursorAccountInfo() async {
    try {
      final dbPath = await getDbPath();
      final db = sqlite3.open(dbPath);

      try {
        final result = db.select(
          'SELECT * FROM itemTable WHERE key = ?',
          ['cursorAuth/accessToken'],
        );
        final exists = result.isNotEmpty;

        if (exists) {
          //https://www.cursor.com/api/auth/me
          final response = await http.post(Uri.parse('https://www.cursor.com/api/auth/me'), headers: {
            'cookie': 'WorkosCursorSessionToken=${result.first['value']}',
          });
          final userInfo = jsonDecode(response.body) as Map<String, dynamic>;
          final userId = userInfo['userId'];
          final usageResponse = await http.get(Uri.parse('https://www.cursor.com/api/usage?user=$userId'), headers: {
            'cookie': 'WorkosCursorSessionToken=${result.first['value']}',
          });

          if (usageResponse.statusCode == 200) {
            final jsonData = jsonDecode(usageResponse.body) as Map<String, dynamic>;
            final userStage = UserStage.fromJson(jsonData['gpt-4']);
            return userStage;
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
      return UserStage();
    }
  }
}
