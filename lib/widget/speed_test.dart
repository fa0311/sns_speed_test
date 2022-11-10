// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sns_speed_test/api/speed_test.dart';
import 'package:sns_speed_test/dataclass/service.dart';
import 'package:sns_speed_test/widget/service_select.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

final servicesProvider = StateProvider((ref) => Services.twitter);

final responseTimeProvider = StateProvider((ref) => 0.0);
final speedProvider = StateProvider((ref) => 0.0);

final connectionProvider = StateProvider((ref) => 20);
final receivedConnectionProvider = StateProvider((ref) => 0);

final receivedProvider = StateProvider((ref) => 0.0);
final contentLengthProvider = StateProvider((ref) => 50.0);

final isProgressProvider = StateProvider((ref) => false);

enum GaugeType {
  time("ms"),
  speed("mbps");

  final String unit;
  const GaugeType(this.unit);
}

class SpeedTestWidget extends ConsumerWidget {
  const SpeedTestWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider);
    final isProgress = ref.watch(isProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Speed Test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (GaugeType type in GaugeType.values)
                  SizedBox(
                    width: 200,
                    height: 250,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final value = () {
                          switch (type) {
                            case GaugeType.time:
                              return ref.watch(responseTimeProvider);
                            case GaugeType.speed:
                              return ref.watch(speedProvider);
                          }
                        }();
                        return SfRadialGauge(
                          axes: <RadialAxis>[
                            RadialAxis(
                              minimum: 0,
                              maximum: 300,
                              ranges: [
                                GaugeRange(startValue: 0, endValue: value, color: Colors.green),
                              ],
                              pointers: [
                                NeedlePointer(value: value),
                              ],
                              annotations: [
                                GaugeAnnotation(
                                  widget: Text(
                                    "${value.toStringAsFixed(2)} ${type.unit}",
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  angle: 90,
                                  positionFactor: 0.5,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 350,
              ),
              child: Column(
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final connection = ref.watch(connectionProvider);
                      final received = ref.watch(receivedConnectionProvider);
                      return SfLinearGauge(
                        minimum: 0.0,
                        maximum: connection.toDouble(),
                        barPointers: [LinearBarPointer(value: received.toDouble())],
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final contentLength = ref.watch(contentLengthProvider);
                      final receved = ref.watch(receivedProvider);
                      return SfLinearGauge(
                        minimum: 0.0,
                        maximum: contentLength.roundToDouble(),
                        barPointers: [LinearBarPointer(value: receved.roundToDouble())],
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(services.name),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: isProgress
                          ? null
                          : () {
                              ref.read(isProgressProvider.notifier).state = true;
                              ref.read(responseTimeProvider.notifier).state = 0.0;
                              ref.read(speedProvider.notifier).state = 0.0;
                              ref.read(receivedProvider.notifier).state = 0.0;
                              SpeedTest test = SpeedTest(ref.read(servicesProvider).getUri());
                              test.download(ref.read(connectionProvider), latency: (value, received) {
                                ref.read(responseTimeProvider.notifier).state = value;
                                ref.read(receivedConnectionProvider.notifier).state = received;
                              }, latencyDone: (value) {
                                ref.read(contentLengthProvider.notifier).state = value / 1024 / 1024;
                              }, listen: (value, received) {
                                ref.read(speedProvider.notifier).state = value / 1024 / 1024;
                                ref.read(receivedProvider.notifier).state = received / 1024 / 1024;
                              }, listenDone: () {
                                ref.read(isProgressProvider.notifier).state = false;
                              });
                            },
                      child: const Text("Start Speed Test"),
                    ),
                  ),
                  const ServicesSelectButton(),
                  Consumer(
                    builder: (context, ref, child) {
                      final connection = ref.watch(connectionProvider);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Slider(
                            value: connection.toDouble(),
                            min: 1,
                            max: 100,
                            onChanged: (value) {
                              ref.read(connectionProvider.notifier).state = value.toInt();
                            },
                          ),
                          Text("Connection $connection"),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
