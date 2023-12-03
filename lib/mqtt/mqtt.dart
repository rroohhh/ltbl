library mqtt;

import 'dart:async';

import 'package:ltbl/util/stream_extensions.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:typed_data/typed_buffers.dart';

part './subscription.dart';

typedef ReceivedMessage = MqttReceivedMessage<MqttMessage>;

class MqttStreamClient {
  late final MqttStreamSubscriptionManager _subscriptionManager;
  final StreamController<MqttConnectionStatus> _connectionStatusController =
      StreamController.broadcast();
  late final Stream<MqttConnectionStatus> connectionStatus;
  final MqttClient _client;
  final String? _username;
  final String? _password;

  MqttStreamClient(
    String serverAddress,
    String uniqueID,
    int port, [
    String? username,
    String? password,
  ])  : _client = MqttServerClient.withPort(serverAddress, uniqueID, port),
        _username = username,
        _password = password {
    _client.autoReconnect = true;
    _client.resubscribeOnAutoReconnect = true;

    // we need to connect before the updates and the published streams
    // are valid, so just forcibly connect here
    _connect();

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

    connectionStatus = _connectionStatusController.stream;
  }

  Future<void> _connect() async {
    try {
      final status = await _client.connect(_username, _password);
      if (status != null) {
        _connectionStatusController.add(status);
      }
    } catch (e) {
      _connectionStatusController.addError(e);
    }
  }

  Future<MqttStreamSubscription> subscribe(String topic, MqttQos qos) async {
    if (!(_client.connectionStatus?.state == MqttConnectionState.connected)) {
      await connectionStatus.firstWhere(
          (status) => status.state == MqttConnectionState.connected);
    }

    return _subscriptionManager.subscribe(topic, qos);
  }

  Future<void> unsubscribe(MqttStreamSubscription subscription) {
    return _subscriptionManager.unsubscribe(subscription);
  }

  Future<MqttPublishMessage> publish(
      String topic, MqttQos qos, Uint8Buffer data,
      {bool retain = false, List<MqttUserProperty>? userProperties}) {
    final publishedSingleStream = _client.published?.toSingleStream();
    final messageID = _client.publishMessage(topic, qos, data);
    return publishedSingleStream!.firstWhere(
        (element) => element.variableHeader!.messageIdentifier == messageID);
  }

  void doReconnect() {
    _client.doAutoReconnect(force: true);
  }
}
