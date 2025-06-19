import 'package:flutter/cupertino.dart';
import 'package:sobienote_flutter/common/const/colors.dart';

class BtnTag extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onPressed;
  const BtnTag({super.key, required this.text, required this.selected, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Container(
          color: selected == true ? DARK_TEAL : GRAY_09,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: selected == true ? GRAY_09 : DARK_GRAY,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ),
    );
  }
}
