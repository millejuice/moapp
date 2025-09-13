import 'package:flutter/material.dart';

class TextSection extends StatelessWidget {
  const TextSection({
    super.key,
    required this.description,
    this.padding = const EdgeInsets.all(32), 
    this.style = const TextStyle(fontWeight: FontWeight.bold), 
  });

  final String description;
  final EdgeInsetsGeometry padding;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        description,
        softWrap: true,
        style: style,
      ),
    );
  }
}
