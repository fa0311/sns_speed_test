import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum Services {
  twitter(icon: FontAwesomeIcons.twitter),
  instagram(icon: FontAwesomeIcons.instagram),
  line(icon: FontAwesomeIcons.line),
  youtube(icon: FontAwesomeIcons.twitter);

  final IconData icon;
  const Services({required this.icon});
}
