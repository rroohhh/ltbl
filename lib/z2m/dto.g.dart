// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LightProperties _$LightPropertiesFromJson(Map<String, dynamic> json) =>
    LightProperties(
      state: $enumDecodeNullable(_$LightStateEnumMap, json['state']),
      brightness: json['brightness'] as int?,
      temperature: json['temperature'] as int?,
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
  writeNotNull('temperature', instance.temperature);
  return val;
}

const _$LightStateEnumMap = {
  LightState.on: 'ON',
  LightState.off: 'OFF',
};
