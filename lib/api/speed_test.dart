import 'package:http/http.dart' as http;

abstract class SpeedTestData {
  Uri url;
  Map<String, String> headers = {'content-type': 'application/json'};
  SpeedTestData(this.url);
}

class SpeedTest extends SpeedTestData {
  bool isProgress = false;
  SpeedTest(super.url);

  download(
    int connectionSize, {
    Function(double, int)? latency,
    Function(int)? latencyDone,
    Function(double, int)? listen,
    Function()? listenDone,
  }) async {
    isProgress = true;
    int receivedLatency = 0;
    List<http.StreamedResponse> tasks = [];

    Stopwatch latencyTime = Stopwatch()..start();
    for (int id = 0; id < connectionSize; id++) {
      tasks.add(await http.Client().send(http.Request('GET', url)));
      if (latency != null) {
        latency(latencyTime.elapsedMilliseconds / (id + 1), ++receivedLatency);
      }
    }
    latencyTime.stop();

    int contentLength = tasks.fold(0, (value, element) => value + (element.contentLength ?? 0));
    if (latencyDone != null) {
      latencyDone(contentLength);
    }

    int doneConnection = 0;
    int received = 0;

    Stopwatch speedTime = Stopwatch()..start();
    for (http.StreamedResponse task in tasks) {
      task.stream.listen((value) {
        received += value.length;
        double sec = speedTime.elapsedMilliseconds / 1000;
        if (listen != null) {
          listen(received * 8 / sec, received);
        }
      }).onDone(() async {
        if (++doneConnection >= connectionSize) {
          speedTime.stop();
          isProgress = false;
          double sec = speedTime.elapsedMilliseconds / 1000;
          if (listen != null) {
            listen(received * 8 / sec, received);
          }
          if (listenDone != null) {
            listenDone();
          }
        }
      });
    }
  }
}
