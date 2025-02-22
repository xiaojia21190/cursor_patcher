import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
part 'user_stage.freezed.dart';
part 'user_stage.g.dart';

@freezed
class UserStage with _$UserStage {
  const factory UserStage({
    String? name,
    String? email,
    String? picture,
    String? sub,
    int? maxRequestUsage,
    int? numRequests,
  }) = _UserStage;

  factory UserStage.fromJson(Map<String, Object?> json) => _$UserStageFromJson(json);
}
