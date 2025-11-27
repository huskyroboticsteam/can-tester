import 'package:flutter/material.dart';

class BoldCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;

  const BoldCard({super.key, required this.child, this.borderRadius = 20});

  static const double borderWidth = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      // pad child so that this container becomes border
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(80, 80, 80, 1),
            Color.fromRGBO(40, 40, 40, 1),
          ],
          transform: GradientRotation(1.57),
        ),
        borderRadius: BorderRadius.circular(borderRadius + borderWidth),
      ),
    
      // main content
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Color.fromRGBO(25, 25, 25, 1),
        ),
    
        child: child,
      ),
    );
  }
}
