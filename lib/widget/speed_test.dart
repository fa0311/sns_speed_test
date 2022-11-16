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

final connectionSizeProvider = StateProvider((ref) => 20);
final connectionProvider = StateProvider((ref) => 0);

final startReceivedProvider = StateProvider((ref) => 0.0);
final receivedProvider = StateProvider((ref) => 0.0);
final endReceivedProvider = StateProvider((ref) => 0.0);

final contentLengthProvider = StateProvider((ref) => 50.0);

final stateProvider = StateProvider((ref) => SpeedTestState.none);

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
    final state = ref.watch(stateProvider);

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
                    width: 180,
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
                                  positionFactor: 0.8,
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
                  const Text("Connected threads"),
                  Consumer(
                    builder: (context, ref, child) {
                      final connection = ref.watch(connectionSizeProvider);
                      final received = ref.watch(connectionProvider);
                      return SfLinearGauge(
                        minimum: 0.0,
                        maximum: connection.toDouble(),
                        barPointers: [LinearBarPointer(value: received.toDouble())],
                      );
                    },
                  ),
                  const Text("Traffic (mb)"),
                  Consumer(
                    builder: (context, ref, child) {
                      final contentLength = ref.watch(contentLengthProvider);
                      final startReceved = ref.watch(startReceivedProvider);
                      final receved = ref.watch(receivedProvider);
                      final endReceved = ref.watch(endReceivedProvider);
                      return SfLinearGauge(
                        minimum: 0.0,
                        maximum: contentLength.roundToDouble(),
                        barPointers: [
                          LinearBarPointer(color: const Color.fromARGB(255, 39, 39, 39), value: endReceved.roundToDouble()),
                          LinearBarPointer(value: receved.roundToDouble()),
                          LinearBarPointer(color: const Color.fromARGB(255, 39, 39, 39), value: startReceved.roundToDouble()),
                        ],
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
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: state == SpeedTestState.none
                          ? () {
                              ref.read(responseTimeProvider.notifier).state = 0.0;
                              ref.read(speedProvider.notifier).state = 0.0;
                              ref.read(startReceivedProvider.notifier).state = 0.0;
                              ref.read(receivedProvider.notifier).state = 0.0;
                              ref.read(endReceivedProvider.notifier).state = 0.0;
                              SpeedTest test = SpeedTest(ref.read(servicesProvider).getUri());
                              test.download(
                                ref.read(connectionSizeProvider),
                                startConnection: (value, received, contentLength) {
                                  ref.read(responseTimeProvider.notifier).state = value;
                                  ref.read(connectionProvider.notifier).state = received;
                                  ref.read(contentLengthProvider.notifier).state = contentLength / 1024 / 1024;
                                },
                                endConnection: (received) {
                                  ref.read(connectionProvider.notifier).state = received;
                                },
                                startListen: (received) {
                                  ref.read(startReceivedProvider.notifier).state = received / 1024 / 1024;
                                },
                                listen: (value, received) {
                                  ref.read(speedProvider.notifier).state = value / 1024 / 1024;
                                  ref.read(receivedProvider.notifier).state = received / 1024 / 1024;
                                },
                                endListen: (received) {
                                  ref.read(endReceivedProvider.notifier).state = received / 1024 / 1024;
                                },
                                changeStateListen: (state) {
                                  ref.read(stateProvider.notifier).state = state;
                                },
                              );
                            }
                          : null,
                      child: const Text("Start Speed Test"),
                    ),
                  ),
                  Text(services.name),
                  const ServicesSelectButton(),
                  Consumer(
                    builder: (context, ref, child) {
                      final connection = ref.watch(connectionSizeProvider);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Connection $connection"),
                          Slider(
                            value: connection.toDouble(),
                            min: 1,
                            max: 100,
                            onChanged: state == SpeedTestState.none
                                ? (value) {
                                    ref.read(connectionSizeProvider.notifier).state = value.toInt();
                                  }
                                : null,
                          ),
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
