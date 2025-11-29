import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;

  const GlassCard({super.key, required this.child, this.borderRadius = 20});

  static const double borderWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      // pad child so that this container becomes border
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(200, 200, 200, 1),
            Color.fromRGBO(80, 80, 80, 1),
          ],
          transform: GradientRotation(0.84),
        ),
        borderRadius: BorderRadius.circular(borderRadius + borderWidth),
      ),
    
      // main content
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(150, 150, 150, 1),
              Color.fromRGBO(85, 85, 85, 1),
            ],
            transform: GradientRotation(1.57),
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
    
        child: child,
      ),
    );
  }
}
