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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Speed Test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (GaugeType type in GaugeType.values)
                  SizedBox(
                    width: 200,
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
            Text(services.name),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(responseTimeProvider.notifier).state = 0.0;
                  ref.read(speedProvider.notifier).state = 0.0;
                  SpeedTest(Uri.parse("https://video.twimg.com/ext_tw_video/1589654926166265856/pu/vid/480x600/qX9Ha_9U-Sl8wggn.mp4")).download(
                    10,
                    ping: (value) {
                      ref.read(responseTimeProvider.notifier).state = value;
                    },
                    listen: (value) {
                      print(value);
                      ref.read(speedProvider.notifier).state = value;
                    },
                  );
                },
                child: const Text("Start Speed Test"),
              ),
            ),
            const ServicesSelectButton(),
          ],
        ),
      ),
    );
  }
}
