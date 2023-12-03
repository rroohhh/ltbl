part of 'mqtt.dart';

class MqttStreamSubscription {
  final Stream<ReceivedMessage> stream;
  final String topic;

  MqttStreamSubscription(this.stream, this.topic);
}

class MqttStreamSubscriptionManager {
  late final Stream<MqttSubscription> _subscriptions;
  late final Stream<MqttSubscription> _unsubscriptions;
  final MqttClient _client;
  final Stream<ReceivedMessage> _updates;

  MqttStreamSubscriptionManager(MqttClient client)
      : _client = client,
        _updates = client.updates.asyncExpand(Stream.fromIterable) {
    final StreamController<MqttSubscription> subscriptionsController =
        StreamController.broadcast();
    final StreamController<MqttSubscription> unsubscriptionsController =
        StreamController.broadcast();

    _subscriptions = subscriptionsController.stream;
    _unsubscriptions = subscriptionsController.stream;

    pushToSubscriptions(MqttSubscription subscription) =>
        subscriptionsController.add(subscription);
    pushToUnsubscriptions(MqttSubscription unsubscription) =>
        unsubscriptionsController.add(unsubscription);

    client.onSubscribed = (subscription) => pushToSubscriptions(subscription);
    client.onSubscribeFail =
        (subscription) => pushToSubscriptions(subscription);
    client.onUnsubscribed =
        (subscription) => pushToUnsubscriptions(subscription);
  }

  Future<MqttStreamSubscription> subscribe(
      String topicToSubscribe, MqttQos qos) async {
    final topicSubToSubscribe = MqttSubscriptionTopic(topicToSubscribe);
    final mySubscription = _subscriptions.firstWhere(
        (subscription) => subscription.topic == topicSubToSubscribe);
    final subscription = _client.subscribe(topicToSubscribe, qos);
    if (subscription == null) {
      throw "Subscription on $topicToSubscribe failed miserably!";
    } else {
      final subscription = await mySubscription;
      if (!(subscription.reasonCode?.isSubscribeSuccess ?? false)) {
        throw "Subscription $topicToSubscribe failed with reason ${subscription.reasonCode}.";
      }
    }

    return MqttStreamSubscription(
        _updates.where((event) =>
            event.topic != null &&
            topicSubToSubscribe.matches(MqttPublicationTopic(event.topic))),
        topicToSubscribe);
  }

  /// Caution: If more than one subscriptions exist for one topic,
  /// all of them will be unsubscribed by calling this function once.
  Future<void> unsubscribe(
      MqttStreamSubscription subscriptionToUnsubscribe) async {
    final myUnsubscription = _unsubscriptions.firstWhere((subscription) =>
        subscription.topic
            .matches(MqttPublicationTopic(subscriptionToUnsubscribe.topic)));
    _client.unsubscribeStringTopic(subscriptionToUnsubscribe.topic);

    final unsubscription = await myUnsubscription;
    if (!(unsubscription.reasonCode?.isUnsubscribeSuccess ?? false)) {
      throw "Unsubscription ${subscriptionToUnsubscribe.topic} failed with reason ${unsubscription.reasonCode}.";
    }
  }
}

extension SubscriptionStatusSuccess on MqttSubscribeReasonCode {
  bool get isSubscribeSuccess {
    return this == MqttSubscribeReasonCode.grantedQos0 ||
        this == MqttSubscribeReasonCode.grantedQos1 ||
        this == MqttSubscribeReasonCode.grantedQos2;
  }

  bool get isUnsubscribeSuccess {
    return this == MqttSubscribeReasonCode.grantedQos0;
  }
}
