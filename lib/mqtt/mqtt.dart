library mqtt;

import 'dart:async';

import 'package:ltbl/util/stream_extensions.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:typed_data/typed_buffers.dart';

part './subscription.dart';

typedef ReceivedMessage = MqttReceivedMessage<MqttMessage>;

// Stream client wrap around the MQQT client to put the updates in a stream
// format be be consumed easily.
// https://pub.dev/documentation/mqtt5_client/latest/mqtt5_client/mqtt5_client-library.html
class MqttStreamClient {
  late final MqttStreamSubscriptionManager _subscriptionManager;
  final StreamController<MqttConnectionStatus> _connectionStatusController =
      StreamController.broadcast();
  Stream<MqttConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;
  final MqttClient _client;

  MqttStreamClient(
    String serverAddress,
    String uniqueID,
    int port, [
    String? username,
    String? password,
  ]) : _client = MqttServerClient.withPort(serverAddress, uniqueID, port) {
    _client.autoReconnect = true;
    _client.resubscribeOnAutoReconnect = true;

    // we need call connect for the updates and the published streams
    // to be valid, so just forcibly connect here to be able
    // to listen to them already in the constructor
    _connect(username, password);

    _subscriptionManager = MqttStreamSubscriptionManager(_client);

    connectionChangedHandler() {
      final status = _client.connectionStatus;
      if (status != null) {
        _connectionStatusController.add(status);
      }
    }

    _client.onDisconnected = connectionChangedHandler;
    _client.onConnected = connectionChangedHandler;
    _client.onAutoReconnect = connectionChangedHandler;
    _client.onAutoReconnected = connectionChangedHandler;
  }

  Future<void> _connect(String? username, String? password) async {
    try {
      final status = await _client.connect(username, password);
      if (status != null) {
        _connectionStatusController.add(status);
      }
    } catch (e) {
      _connectionStatusController.addError(e);
    }
  }

  Future<MqttStreamSubscription> subscribe(String topic, MqttQos qos) async {
    await waitForConnection();

    return _subscriptionManager.subscribe(topic, qos);
  }

  Future<void> unsubscribe(MqttStreamSubscription subscription) async {
    await waitForConnection();
    return _subscriptionManager.unsubscribe(subscription);
  }

  Future<MqttPublishMessage> publish(
      String topic, MqttQos qos, Uint8Buffer data,
      {bool retain = false, List<MqttUserProperty>? userProperties}) async {
    await waitForConnection();
    final publishedSingleStream = _client.published?.toSingleStream();
    final messageID = _client.publishMessage(topic, qos, data);
    return await publishedSingleStream!.firstWhere(
        (element) => element.variableHeader!.messageIdentifier == messageID);
  }

  void doReconnect() {
    _client.doAutoReconnect(force: true);
  }

  Future<void> waitForConnection() async {
    if (!(_client.connectionStatus?.state == MqttConnectionState.connected)) {
      await connectionStatus.firstWhere(
          (status) => status.state == MqttConnectionState.connected);
    }
  }
}
