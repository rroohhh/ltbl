import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ltbl/z2m/z2m_service.dart';

class Dashboard extends HookConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lightState = useState(false);

    final Z2MService service = ref.watch(z2MServiceProvider);

    return Scaffold(
      body: Column(
        children: [
          Switch(
            value: lightState.value,
            onChanged: (newValue) => lightState.value = newValue,
          ),
          Text(
            service.getLampName(),
          ),
        ],
      ),
    );
  }
}
