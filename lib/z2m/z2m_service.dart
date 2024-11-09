import 'dart:convert';

import 'package:ltbl/config/light_config.dart';
import 'package:ltbl/config/server_config.dart';
import 'package:ltbl/mqtt/mqtt.dart';
import 'package:ltbl/util/string_extensions.dart';
import 'package:ltbl/z2m/model/light_properties.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'z2m_service.g.dart';

// Service to interact with Zigbee2MQTT Broker
// Docs https://www.zigbee2mqtt.io/guide/usage/mqtt_topics_and_messages.html
class Z2MService {
  final MqttStreamClient _mqttStreamClient;
  Stream<MqttConnectionStatus> get connectionStatus =>
      _mqttStreamClient.connectionStatus;

  Z2MService(String serverAddress, String uniqueID, int port)
      : _mqttStreamClient = MqttStreamClient(serverAddress, uniqueID, port);

  Future<void> setLight(bool state, int brightness, String topic) async {
    await _mqttStreamClient.publish(
      "${LightConfig.topicPrefix}/$topic/set",
      MqttQos.exactlyOnce,
      jsonEncode(LightProperties(
              state: LightState.fromBool(state), brightness: brightness))
          .bytes,
    );
  }

  Future<MqttStreamSubscription> subscribeLight(String topicName) async {
    final result = await _mqttStreamClient.subscribe(
      "${LightConfig.topicPrefix}/$topicName",
      MqttQos.atLeastOnce,
    );

    await _mqttStreamClient.publish(
      "${LightConfig.topicPrefix}/$topicName/get",
      MqttQos.exactlyOnce,
      jsonEncode(LightProperties(state: LightState.off, brightness: 0)).bytes,
    );

    return result;
  }

  Future<void> unsubscribeLight(MqttStreamSubscription subscription) async {
    return await _mqttStreamClient.unsubscribe(subscription);
  }

  Future<MqttStreamSubscription> getAllDevices() async {
    return await _mqttStreamClient.subscribe(
      '${LightConfig.topicPrefix}/bridge/devices',
      MqttQos.atLeastOnce,
    );
  }

  void doReconnect() {
    _mqttStreamClient.doReconnect();
  }
}

@riverpod
Z2MService z2MService(Z2MServiceRef ref) {
  return Z2MService(
      ServerConfig.serverAddress, ServerConfig.uniqueID, ServerConfig.port);
}
