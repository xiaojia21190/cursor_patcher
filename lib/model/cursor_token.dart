import 'package:freezed_annotation/freezed_annotation.dart';

part 'cursor_token.freezed.dart';

@freezed
class CursorToken with _$CursorToken {
  const factory CursorToken({
    required String macMachineId,
    required String machineId,
    required String devDeviceId,
    required String email,
    required String token,
  }) = _CursorToken;
}
