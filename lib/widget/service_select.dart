// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sns_speed_test/dataclass/service.dart';

final editNoteProvider = StateProvider<bool>((ref) => false);

class ServicesSelectButton extends ConsumerWidget {
  const ServicesSelectButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          builder: (_) {
            return Column(
              children: <Widget>[
                for (Services service in Services.values)
                  ListTile(
                    title: Text(service.name),
                    onTap: () => Navigator.of(context).pop(),
                  ),
              ],
            );
          },
        );
      },
      child: const Text('Services Select Button'),
    );
  }
}
