import 'package:freezed_annotation/freezed_annotation.dart';
part 'token_data.freezed.dart';
part 'token_data.g.dart';

@freezed
class TokenData with _$TokenData {
  const factory TokenData({
    @JsonKey(name: 'mac_machine_id') String? macMachineId,
    @JsonKey(name: 'machine_id') String? machineId,
    @JsonKey(name: 'dev_device_id') String? devDeviceId,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'token') String? token,
  }) = _TokenData;

  factory TokenData.fromJson(Map<String, Object?> json) => _$TokenDataFromJson(json);
}
