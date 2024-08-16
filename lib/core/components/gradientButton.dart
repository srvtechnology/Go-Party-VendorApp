import 'package:flutter/material.dart';
import 'package:utsavlife/core/utils/UIColor.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color> colors;
  bool buttonInsideMaterialBox = false;

  GradientButton(
      {Key? key,
      required this.text,
      required this.onPressed,
      this.colors = const [UIColor.theme_color, UIColor.theme_color],
      this.buttonInsideMaterialBox = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color1 = colors.indexOf(colors.first.withOpacity(0.8), 0);
    final color2 = colors.indexOf(colors.first.withOpacity(0.4), 1);

    final gradientColor = [
      colors[0].withOpacity(0.8),
      colors[1].withOpacity(0.4)
    ];

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: buttonInsideMaterialBox?  0 : 15),
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColor,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
