class LightStatus {
  final String? state;
  final int? brightness;
  final String? color;
  final String? colorTemp;
  final String? effect;
  final String? linkquality;
  final String? mode;
  final String? update;

  LightStatus({
    this.state,
    this.brightness,
    this.color,
    this.colorTemp,
    this.effect,
    this.linkquality,
    this.mode,
    this.update,
  });

  factory LightStatus.fromJson(Map<String, dynamic> json) {
    return LightStatus(
      state: json['state'],
      brightness: json['brightness'],
      color: json['color'],
      colorTemp: json['color_temp'],
      effect: json['effect'],
      linkquality: json['linkquality'],
      mode: json['mode'],
      update: json['update'],
    );
  }
}
