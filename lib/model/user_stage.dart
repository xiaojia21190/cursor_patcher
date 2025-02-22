import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
part 'user_stage.freezed.dart';
part 'user_stage.g.dart';

@freezed
class UserStage with _$UserStage {
  const factory UserStage({
    int? id,
    String? email,
    String? contributor,
    int? remaining,
    int? status,
    @JsonKey(name: 'total_used') int? totalUsed,
    @JsonKey(name: 'total_available') int? totalAvailable,
    @JsonKey(name: 'disable_reason') String? disableReason,
  }) = _UserStage;

  factory UserStage.fromJson(Map<String, Object?> json) => _$UserStageFromJson(json);
}
