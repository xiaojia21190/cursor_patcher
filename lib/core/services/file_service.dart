import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';
import '../models/token_data.dart';

class FileService {
  final Logger _logger = Logger('FileService');

  Future<void> makeFileWritable(String filePath) async {
    try {
      if (Platform.isWindows) {
        await Process.run('attrib', ['-R', filePath]);
      } else {
        await Process.run('chmod', ['666', filePath]);
      }
    } catch (e) {
      _logger.severe('修改文件权限失败: $e');
      rethrow;
    }
  }

  Future<void> makeFileReadonly(String filePath) async {
    try {
      if (Platform.isWindows) {
        await Process.run('attrib', ['+R', filePath]);
      } else {
        await Process.run('chmod', ['444', filePath]);
      }
    } catch (e) {
      _logger.severe('修改文件权限失败: $e');
      rethrow;
    }
  }

  Future<bool> resetCursorId(String storagePath, TokenData tokenData) async {
    if (!File(storagePath).existsSync()) {
      _logger.warning('未找到文件: $storagePath');
      return false;
    }

    try {
      await makeFileWritable(storagePath);

      final file = File(storagePath);
      final content = await file.readAsString();
      final data = json.decode(content) as Map<String, dynamic>;

      data.addAll({
        'telemetry.macMachineId': tokenData.macMachineId,
        'telemetry.machineId': tokenData.machineId,
        'telemetry.devDeviceId': tokenData.devDeviceId,
      });

      await file.writeAsString(json.encode(data));
      await makeFileReadonly(storagePath);

      _logger.info('Cursor 机器码已成功修改');
      return true;
    } catch (e) {
      _logger.severe('重置 Cursor 机器码时发生错误: $e');
      return false;
    }
  }
}
