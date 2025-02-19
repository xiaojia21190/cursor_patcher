import 'package:freezed_annotation/freezed_annotation.dart';
part 'cursor_helper.freezed.dart';
part 'cursor_helper.g.dart';

@freezed
class CursorHelper with _$CursorHelper {
  const factory CursorHelper({
    @JsonKey(name: 'auth_code') String? authCode,
    @JsonKey(name: 'today_remaining') int? todayRemaining,
    @JsonKey(name: 'max_daily_limit') int? maxDailyLimit,
    @JsonKey(name: 'total_used') int? totalUsed,
  }) = _CursorHelper;

  factory CursorHelper.fromJson(Map<String, Object?> json) => _$CursorHelperFromJson(json);
}
