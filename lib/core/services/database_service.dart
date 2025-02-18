// import 'package:sqlite3/sqlite3.dart';
// import 'package:logging/logging.dart';
// import '../constants/app_constants.dart';

// class DatabaseService {
//   final Logger _logger = Logger('DatabaseService');
//   final String dbPath;

//   DatabaseService(this.dbPath);

//   Future<bool> updateAuth({
//     String? email,
//     String? accessToken,
//     String? refreshToken,
//   }) async {
//     if (email == null && accessToken == null && refreshToken == null) {
//       _logger.info('没有提供任何要更新的值');
//       return false;
//     }

//     try {
//       final db = sqlite3.open(dbPath);

//       final updates = <Map<String, String>>[];
//       if (email != null) {
//         updates.add({
//           'key': AppConstants.dbKeys['email']!,
//           'value': email,
//         });
//       }
//       if (accessToken != null) {
//         updates.add({
//           'key': AppConstants.dbKeys['access_token']!,
//           'value': accessToken,
//         });
//       }
//       if (refreshToken != null) {
//         updates.add({
//           'key': AppConstants.dbKeys['refresh_token']!,
//           'value': refreshToken,
//         });
//       }

//       for (final update in updates) {
//         final result = db.select(
//           'SELECT 1 FROM itemTable WHERE key = ?',
//           [update['key']],
//         );

//         if (result.isNotEmpty) {
//           db.execute(
//             'UPDATE itemTable SET value = ? WHERE key = ?',
//             [update['value'], update['key']],
//           );
//         } else {
//           db.execute(
//             'INSERT INTO itemTable (key, value) VALUES (?, ?)',
//             [update['key'], update['value']],
//           );
//         }
//         _logger.info('成功${result.isNotEmpty ? "更新" : "插入"} ${update["key"]?.split("/")?.last}');
//       }

//       db.dispose();
//       return true;
//     } catch (e) {
//       _logger.severe('数据库错误: $e');
//       return false;
//     }
//   }
// }
