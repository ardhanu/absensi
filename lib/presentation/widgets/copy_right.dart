import 'package:flutter/material.dart';

class CopyrightText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const CopyrightText({
    Key? key,
    this.text = '© 2025 Sakti Ardhanu. All rights reserved.',
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          style ??
          Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
      textAlign: TextAlign.center,
    );
  }
}
