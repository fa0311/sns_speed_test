import 'package:http/http.dart' as http;

abstract class SpeedTestData {
  Uri url;
  Map<String, String> headers = {'content-type': 'application/json'};
  SpeedTestData(this.url);
}

enum SpeedTestState {
  none,
  start,
  progress,
  end;
}

class SpeedTest extends SpeedTestData {
  SpeedTestState state = SpeedTestState.none;
  SpeedTest(super.url);

  download(
    int connectionSize, {
    Function(double, int, int)? latency,
    Function(int)? startListen,
    Function(double, int)? listen,
    Function(int)? endListen,
    Function(SpeedTestState)? changeStateListen,
  }) async {
    if (changeStateListen != null) changeStateListen(state = SpeedTestState.start);

    int received = 0;
    int contentLength = 0;
    int progressLatency = 0;

    Stopwatch speedTime = Stopwatch()..start();
    Stopwatch latencyTime = Stopwatch()..start();
    for (int id = 0; id < connectionSize; id++) {
      http.Client().send(http.Request('GET', url)).then((task) {
        contentLength += task.contentLength ?? 0;
        if (latency != null) {
          latency(latencyTime.elapsedMilliseconds.toDouble(), ++progressLatency, contentLength);
        }
        if (connectionSize == progressLatency) {
          if (changeStateListen != null) changeStateListen(state = SpeedTestState.progress);
        }
        task.stream.listen((value) {
          received += value.length;

          switch (state) {
            case SpeedTestState.none:
              return;
            case SpeedTestState.start:
              if (startListen != null) startListen(received);
              return;
            case SpeedTestState.progress:
              double sec = speedTime.elapsedMilliseconds / 1000;
              if (listen != null) listen(received * 8 / sec, received);
              return;
            case SpeedTestState.end:
              if (endListen != null) endListen(received);
              return;
          }
        }).onDone(() async {
          if (connectionSize == progressLatency) {
            if (changeStateListen != null) changeStateListen(state = SpeedTestState.end);
          }
          if (--progressLatency == 0) {
            if (changeStateListen != null) changeStateListen(state = SpeedTestState.none);
          }
        });
      });
    }
  }
}
