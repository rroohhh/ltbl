import 'dart:convert';
import 'dart:ffi';

class Device {
  bool disabled;
  String friendlyName;
  String ieeeAddress;
  int networkAddress;
  bool? suppported;
  String type;

  Device(this.friendlyName, this.ieeeAddress, this.type, this.networkAddress,
      this.disabled, this.suppported);

  Device.fromJson(Map<String, dynamic> json)
      : friendlyName = json['friendly_name'],
        ieeeAddress = json['ieee_address'],
        type = json['type'],
        disabled = json['disabled'],
        suppported = json['suppprted'],
        networkAddress = json['network_address'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['friendly_name'] = friendlyName;
    data['ieee_address'] = ieeeAddress;
    data['type'] = type;
    data['network_address'] = networkAddress;
    data['disabled'] = disabled;
    data['suppprted'] = suppported;
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

  List<Device> get lampDevices =>
      allDevices.where((element) => element.type == 'Router').toList();
}
