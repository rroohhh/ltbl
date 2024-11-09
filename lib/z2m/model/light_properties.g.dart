// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'light_properties.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LightProperties _$LightPropertiesFromJson(Map<String, dynamic> json) =>
    LightProperties(
      state: $enumDecodeNullable(_$LightStateEnumMap, json['state']),
      brightness: json['brightness'] as int?,
      colorTemp: json['color_temp'] as int?,
    );

Map<String, dynamic> _$LightPropertiesToJson(LightProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('state', _$LightStateEnumMap[instance.state]);
  writeNotNull('brightness', instance.brightness);
  writeNotNull('color_temp', instance.colorTemp);
  return val;
}

const _$LightStateEnumMap = {
  LightState.on: 'ON',
  LightState.off: 'OFF',
};
