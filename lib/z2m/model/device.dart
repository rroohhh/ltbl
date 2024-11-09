import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'device.g.dart';

@JsonSerializable()
class Device {
  @JsonKey(includeIfNull: false, name: 'friendly_name')
  String? friendlyName;

  @JsonKey(includeIfNull: false, name: 'ieee_address')
  String ieeeAddress;

  @JsonKey(includeIfNull: false)
  String? type;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  Device({this.friendlyName, required this.ieeeAddress, this.type});
  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}

class DeviceList {
  List<Device> allDevices;

  DeviceList(this.allDevices);

  DeviceList.fromString(String data)
      : allDevices =
            jsonDecode(data).map<Device>((x) => Device.fromJson(x)).toList();

  List<Device> get lampDevices =>
      allDevices.where((element) => element.type == 'Router').toList();
}
