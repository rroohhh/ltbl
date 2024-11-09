import 'package:json_annotation/json_annotation.dart';

part 'dto.g.dart';

@JsonEnum()
enum LightState {
  @JsonValue("ON")
  on,
  @JsonValue("OFF")
  off;

  factory LightState.fromBool(bool state) {
    if (state) {
      return LightState.on;
    } else {
      return LightState.off;
    }
  }
}

@JsonSerializable()
class LightProperties {
  @JsonKey(includeIfNull: false)
  final LightState? state;
  @JsonKey(includeIfNull: false)
  final int? brightness;
  @JsonKey(includeIfNull: false)
  final int? temperature;

  factory LightProperties.fromJson(Map<String, dynamic> json) =>
      _$LightPropertiesFromJson(json);

  LightProperties({this.state, this.brightness, this.temperature});
  Map<String, dynamic> toJson() => _$LightPropertiesToJson(this);
}
