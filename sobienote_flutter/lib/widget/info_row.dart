import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  final TextStyle? labelStyle;

  const InfoRow({
    super.key,
    required this.label,
    required this.trailing,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          trailing,
        ],
      ),
    );
  }
}
