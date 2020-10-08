import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget {
  final double height;
  final Gradient gradient;
  final Widget child;
  GradientAppBar(
      {@required this.gradient, this.height = 50.0, @required this.child});

  @override
  Widget build(BuildContext context) {
    final double statusbarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: statusbarHeight),
      height: statusbarHeight + height,
      child: Center(
        child: child,
      ),
      decoration: BoxDecoration(
        gradient: gradient,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.yellow,
            blurRadius: 1.0, // soften the shadow
            spreadRadius: 1.0, //extend the shadow
            offset: Offset(
              0.0, // Move to right 10  horizontally
              -10.0, // Move to bottom 10 Vertically
            ),
          )
        ],
      ),
    );
  }
}
