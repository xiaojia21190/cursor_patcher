class AppConstants {
  static const String apiUrl = "https://cursor.ccopilot.org/api/get_next_token.php";
  static const String accessCode = "";
  static const int processTimeout = 5;
  static const List<String> cursorProcessNames = ['cursor.exe', 'cursor'];
  static const Map<String, String> dbKeys = {'email': 'cursorAuth/cachedEmail', 'access_token': 'cursorAuth/accessToken', 'refresh_token': 'cursorAuth/refreshToken'};
  static const String minPatchVersion = "0.45.0";
  static const String versionPattern = r"^\d+\.\d+\.\d+$";
  static const String scriptVersion = "2025020801";
}
