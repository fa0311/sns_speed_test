// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sns_speed_test/api/speed_test.dart';
import 'package:sns_speed_test/widget/service_select.dart';

class SpeedTestWidget extends ConsumerWidget {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController countController = TextEditingController();

  SpeedTestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Speed Test"),
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const ServicesSelectButton(),
              TextButton(
                onPressed: () {
                  SpeedTest(Uri.parse(urlController.text)).download(int.parse(countController.text));
                },
                child: const Text("Test"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
