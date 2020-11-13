import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AnimatedQuestionCounter extends StatefulWidget {
  final Widget child;
  final Duration slideDuration, stayDuration;
  final Function onEnd;
  AnimatedQuestionCounter(
      {Key key,
      @required this.child,
      @required this.slideDuration,
      @required this.stayDuration,
      @required this.onEnd})
      : super(key: key);

  @override
  _AnimatedQuestionCounterState createState() =>
      _AnimatedQuestionCounterState();
}

class _AnimatedQuestionCounterState extends State<AnimatedQuestionCounter> {
  AlignmentGeometry _alignment = Alignment.topCenter;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _alignment = Alignment.center;
        _opacity = 1.0;
      });
      Future.delayed(widget.stayDuration, () {
        setState(() {
          _alignment = Alignment.bottomCenter;
          _opacity = 0.0;
        });
        Future.delayed(widget.slideDuration, () {
          widget.onEnd();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: AnimatedAlign(
          alignment: _alignment,
          curve: Curves.easeIn,
          duration: widget.slideDuration,
          child: AnimatedOpacity(
            duration: widget.slideDuration,
            opacity: _opacity,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
