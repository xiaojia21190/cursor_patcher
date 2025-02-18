// import 'package:logging/logging.dart';
// import '../../core/services/platform_service.dart';
// import '../../core/services/database_service.dart';
// import '../../core/services/file_service.dart';
// import '../../core/models/token_data.dart';

// class CursorRepository {
//   final Logger _logger = Logger('CursorRepository');
//   final PlatformService _platformService;
//   final DatabaseService _databaseService;
//   final FileService _fileService;

//   CursorRepository({
//     required PlatformService platformService,
//     required DatabaseService databaseService,
//     required FileService fileService,
//   })  : _platformService = platformService,
//         _databaseService = databaseService,
//         _fileService = fileService;

//   Future<bool> updateToken(TokenData tokenData) async {
//     try {
//       final storagePath = await _platformService.getStoragePath();

//       // 更新机器ID
//       if (!await _fileService.resetCursorId(storagePath, tokenData)) {
//         return false;
//       }

//       // 更新认证信息
//       if (!await _databaseService.updateAuth(
//         email: tokenData.email,
//         accessToken: tokenData.token,
//         refreshToken: tokenData.token,
//       )) {
//         _logger.severe('更新 Token 时发生错误');
//         return false;
//       }

//       _logger.info('成功更新 Cursor 认证信息! 邮箱: ${tokenData.email}');
//       return true;
//     } catch (e) {
//       _logger.severe('更新 Token 时发生错误: $e');
//       return false;
//     }
//   }
// }
