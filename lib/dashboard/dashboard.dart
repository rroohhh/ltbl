import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ltbl/util/async_snapshot_extensions.dart';
import 'package:ltbl/z2m/z2m_service.dart';

class Dashboard extends HookConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lightState = useState(true);
    final brightness = useState(1.0);
    final z2mService = ref.watch(z2MServiceProvider);
    final connectionStatus = useFuture(z2mService.connectionStatus);

    useEffect(() {
      z2mService.setLight(lightState.value, (brightness.value * 256).toInt());
      return;
    }, [lightState.value, brightness.value, z2mService]);

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 100),
          Switch(
            value: lightState.value,
            onChanged: (newValue) => lightState.value = newValue,
          ),
          Slider(
            value: brightness.value,
            onChanged: (newBrightness) => brightness.value = newBrightness,
          ),
          connectionStatus.when(
            onSuccess: (data) => Text("$data"),
            onError: (error) => Text(
              "$error",
              style: const TextStyle(color: Colors.red),
            ),
            onLoading: () => const CircularProgressIndicator(),
          )
        ],
      ),
    );
  }
}
