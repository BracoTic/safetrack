import 'package:flutter/material.dart';

class MenuOption {
  final String title;
  final IconData icon;
  final Color color;
  final void Function(BuildContext context) onTap;

  MenuOption({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
