import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ltbl/mqtt/mqtt.dart';
import 'package:ltbl/util/async_snapshot_extensions.dart';
import 'package:ltbl/z2m/model/device.dart';
import 'package:ltbl/z2m/model/light_properties.dart';
import 'package:ltbl/z2m/z2m_service.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

class SimpleControl extends HookConsumerWidget {
  const SimpleControl({
    super.key,
    required this.currentDevice,
  });

  final Device currentDevice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lightState = useState(true);
    final brightness = useState(1.0);
    final z2mService = ref.watch(z2MServiceProvider);
    final subscriptionInfo = useState<MqttStreamSubscription?>(null);
    final lightStream =
        useStream<ReceivedMessage>(subscriptionInfo.value?.stream);

    useEffect(() {
      z2mService
          .setLight(lightState.value, (brightness.value * 256).toInt(),
              currentDevice.ieeeAddress)
          .onError((error, _) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("$error")));
      });
      return;
    }, [lightState.value, brightness.value, z2mService]);

    useEffect(() {
      z2mService.subscribeLight(currentDevice.ieeeAddress).then((value) {
        subscriptionInfo.value = value;
      });
      return;
    }, [z2mService]);

    lightStream.when(onSuccess: (data) {
      final publishMessage = data.payload as MqttPublishMessage;
      final lightMsg =
          MqttUtilities.bytesToStringAsString(publishMessage.payload.message!);
      final light = LightProperties.fromJson(jsonDecode(lightMsg));
      lightState.value = light.state == LightState.on;
      brightness.value = light.brightness! / 256;
    }, onError: (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$error")));
    }, onLoading: () {
      // Todo
    });

    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(currentDevice.friendlyName ?? 'unknown'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Switch(
                  value: lightState.value,
                  onChanged: (newValue) => lightState.value = newValue,
                ),
                const SizedBox(width: 8),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Slider(
                  value: brightness.value,
                  onChanged: (newBrightness) =>
                      brightness.value = newBrightness,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
