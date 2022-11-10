import 'package:http/http.dart' as http;

abstract class SpeedTestData {
  Uri url;
  Map<String, String> headers = {'content-type': 'application/json'};
  SpeedTestData(this.url);
}

class SpeedTest extends SpeedTestData {
  int received = 0;
  bool isProgress = false;
  SpeedTest(super.url);

  download(
    int connectionSize, {
    Function(double)? ping,
    Function(double)? listen,
  }) async {
    isProgress = true;
    int doneConnection = 0;
    List<http.StreamedResponse> tasks = [];

    Stopwatch pingTime = Stopwatch()..start();
    for (int id = 0; id < connectionSize; id++) {
      tasks.add(await http.Client().send(http.Request('GET', url)));
      if (ping != null) {
        ping(pingTime.elapsedMilliseconds / (id + 1));
      }
    }
    pingTime.stop();

    // int contentLength = tasks.fold(0, (value, element) => value + (element.contentLength ?? 0));

    Stopwatch speedTime = Stopwatch()..start();
    for (http.StreamedResponse task in tasks) {
      task.stream.listen((value) {
        received += value.length;
        double sec = speedTime.elapsedMilliseconds / 1000;
        if (listen != null) {
          listen(received * 8 / 1024 / 1024 / sec);
        }
      }).onDone(() async {
        if (++doneConnection >= connectionSize) {
          speedTime.stop();
          double sec = speedTime.elapsedMilliseconds / 1000;
          if (listen != null) {
            listen(received * 8 / 1024 / 1024 / sec);
          }
        }
      });
    }
  }
}
