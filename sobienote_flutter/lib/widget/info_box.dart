import 'package:flutter/material.dart';
import 'package:sobienote_flutter/common/const/colors.dart';

class InfoBox extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const InfoBox({
    super.key,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: 15),
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        border: Border.all(color: GRAY_06),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: GRAY_09,
      ),
      padding: padding,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
