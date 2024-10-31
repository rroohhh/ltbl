import 'dart:convert';

class Device {
  String friendlyName;
  String ieeeAddress;
  String type;

  Device(this.friendlyName, this.ieeeAddress, this.type);

  Device.fromJson(Map<String, dynamic> json)
      : friendlyName = json['friendly_name'],
        ieeeAddress = json['ieee_address'],
        type = json['type'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['friendly_name'] = friendlyName;
    data['ieee_address'] = ieeeAddress;
    data['type'] = type;
    return data;
  }

  static List<Device> fromString(String data) {
    List<dynamic> d = json.decode(data.trim());
    List<Device> list = List<Device>.from(d.map((x) => Device.fromJson(x)));
    return list;
  }
}

class DeviceList {
  List<Device> allDevices;

  DeviceList(this.allDevices);

  DeviceList.fromString(String data)
      : allDevices = List<Device>.from(
            json.decode(data.trim()).map((x) => Device.fromJson(x)));

  get lampDevices => allDevices.where((element) => element.type == 'Router');
}
