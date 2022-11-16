import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum Services {
  twitter(icon: FontAwesomeIcons.twitter),
  github(icon: FontAwesomeIcons.github),
  line(icon: FontAwesomeIcons.line);

  final IconData icon;
  const Services({required this.icon});

  Uri getUri() {
    switch (this) {
      case Services.twitter:
        return Uri.https(
          "video.twimg.com",
          "/ext_tw_video/1589654926166265856/pu/vid/480x600/qX9Ha_9U-Sl8wggn.mp4",
        );
      case Services.github:
        return Uri.https(
          "github.com",
          "/fa0311/sns_speed_test/releases/download/v1.0.0/app-release.apk",
        );
      case Services.line:
        return Uri.https(
          "obs.line-scdn.net",
          "/hWIwItmgWFGcfXAdpKAoTHjZkH0g1W051CSMaRRB7KQkPSzxrCCBCST1oPR0GZg52CR4sAQ5WVwoyZU55CVQzAQRJKlIbdRl7JjM3RhRsDF4YVg/mp4",
        );
    }
  }
}
