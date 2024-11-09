// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
      friendlyName: json['friendly_name'] as String?,
      ieeeAddress: json['ieee_address'] as String,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$DeviceToJson(Device instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('friendly_name', instance.friendlyName);
  val['ieee_address'] = instance.ieeeAddress;
  writeNotNull('type', instance.type);
  return val;
}
