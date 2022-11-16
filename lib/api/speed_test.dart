import 'package:http/http.dart' as http;

abstract class SpeedTestData {
  Uri url;
  Map<String, String> headers = {'content-type': 'application/json'};
  SpeedTestData(this.url);
}

enum SpeedTestState { none, start, progress, end }

class SpeedTest extends SpeedTestData {
  SpeedTestState state = SpeedTestState.none;
  SpeedTest(super.url);

  download(
    int connectionSize, {
    Function(double, int, int)? startConnection,
    Function(int)? endConnection,
    Function(int)? startListen,
    Function(double, int)? listen,
    Function(int)? endListen,
    Function(SpeedTestState)? changeStateListen,
  }) async {
    if (changeStateListen != null) changeStateListen(state = SpeedTestState.start);

    int received = 0;
    int contentLength = 0;
    int connection = 0;
    int latencySumTime = 0;

    Stopwatch speedTime = Stopwatch()..start();
    Stopwatch latencyTime = Stopwatch()..start();
    for (int id = 0; id < connectionSize; id++) {
      http.Client().send(http.Request('GET', url)).then((task) {
        contentLength += task.contentLength ?? 0;
        latencySumTime += latencyTime.elapsedMilliseconds;
        if (startConnection != null) {
          startConnection(latencySumTime / ++connection, connection, contentLength);
        }
        if (connectionSize == connection) {
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
          if (connectionSize == connection) {
            if (changeStateListen != null) changeStateListen(state = SpeedTestState.end);
          }
          if (--connection == 0) {
            if (changeStateListen != null) changeStateListen(state = SpeedTestState.none);
          }
          if (endConnection != null) endConnection(connection);
        });
      });
    }
  }
}
