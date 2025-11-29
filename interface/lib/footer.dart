import 'package:can_interface/glass-widgets.dart';
import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  // overall height of footer
  static const double height = 24;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: GlassCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("CAN Tester 1.0 Alpha"),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Right Side"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
