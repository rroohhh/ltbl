import 'dart:convert';

import 'package:ltbl/config/light_config.dart';
import 'package:ltbl/config/server_config.dart';
import 'package:ltbl/util/string_extensions.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'z2m_service.g.dart';

class Z2MService {
  final MqttClient client;
  late final Future<MqttConnectionStatus?> connectionStatus;

  Z2MService(String serverAddress, String uniqueID, int port)
      : client = MqttServerClient.withPort(serverAddress, uniqueID, port) {
    connectionStatus = client.connect();
  }

  void setLight(bool state, int brightness) {
    client.publishMessage(
        LightConfig.topic,
        MqttQos.exactlyOnce,
        jsonEncode({
          "state": state ? "ON" : "OFF",
          "brightness": brightness,
        }).bytes);
  }
}

@riverpod
Z2MService z2MService(Z2MServiceRef ref) {
  return Z2MService(
      ServerConfig.serverAddress, ServerConfig.uniqueID, ServerConfig.port);
}
