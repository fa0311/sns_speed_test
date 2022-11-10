import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum Services {
  twitter(icon: FontAwesomeIcons.twitter);

  final IconData icon;
  const Services({required this.icon});

  Uri getUri() {
    switch (this) {
      case Services.twitter:
        return Uri.https("video.twimg.com", "/ext_tw_video/1589654926166265856/pu/vid/480x600/qX9Ha_9U-Sl8wggn.mp4");
    }
  }
}
