import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ltbl/controls/simple_control.dart';
import 'package:ltbl/mqtt/mqtt.dart';
import 'package:ltbl/util/async_snapshot_extensions.dart';
import 'package:ltbl/z2m/model/device.dart';
import 'package:ltbl/z2m/z2m_service.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

class Dashboard extends HookConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z2mService = ref.watch(z2MServiceProvider);
    final deviceInfoSub = useState<MqttStreamSubscription?>(null);
    final deviceInfoStream =
        useStream<ReceivedMessage>(deviceInfoSub.value?.stream);

    useEffect(() {
      z2mService.getAllDevices().then((value) {
        deviceInfoSub.value = value;
      });
      return;
    }, [z2mService]);

    return Scaffold(
      body: deviceInfoStream.when(
        onSuccess: (data) {
          final publishMessage = data.payload as MqttPublishMessage;
          var devicesMsg = MqttUtilities.bytesToStringAsString(
              publishMessage.payload.message!);
          var devices = DeviceList.fromString(devicesMsg).lampDevices;
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              return SimpleControl(currentDevice: devices[index]);
            },
          );
        },
        onError: (error) => Text(
          "$error",
          style: const TextStyle(color: Colors.red),
        ),
        onLoading: () => const CircularProgressIndicator(),
      ),
    );
  }
}
