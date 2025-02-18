class TokenData {
  final String macMachineId;
  final String machineId;
  final String devDeviceId;
  final String email;
  final String token;

  TokenData({
    required this.macMachineId,
    required this.machineId,
    required this.devDeviceId,
    required this.email,
    required this.token,
  });

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      macMachineId: json['mac_machine_id'],
      machineId: json['machine_id'],
      devDeviceId: json['dev_device_id'],
      email: json['email'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mac_machine_id': macMachineId,
      'machine_id': machineId,
      'dev_device_id': devDeviceId,
      'email': email,
      'token': token,
    };
  }
}
