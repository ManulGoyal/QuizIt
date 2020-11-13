import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quizit/quiz_management.dart';
import 'package:quizit/utilities.dart';
import 'package:quizit/web_socket_connection.dart';
import 'package:quizit/custom_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:avatar_glow/avatar_glow.dart';

final double maxShadowRadius = 15;

class QuestionDisplay extends StatefulWidget {
  final QuizQuestion question;
  final Function(String) onEnd;
  final Duration stayDuration;

  QuestionDisplay(
      {Key key,
      @required this.question,
      @required this.onEnd,
      @required this.stayDuration})
      : super(key: key);

  @override
  _QuestionDisplayState createState() => _QuestionDisplayState();
}

class _QuestionDisplayState extends State<QuestionDisplay>
    with TickerProviderStateMixin {
  AnimationController _timerAnimationController, _choicesAnimationController;
  Animation<double> _timerAnimation, _choicesAnimation;
  int timeLeft;
  int markedAnswer;
  double _opacity = 0.0;
  // List<Color> choiceColors = [
  //   customBlue[1],
  //   customBlue[1],
  //   customBlue[1],
  //   customBlue[1]
  // ];

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    _choicesAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    // _animationController.repeat(reverse: true);
    _choicesAnimation = Tween(begin: 0.0, end: maxShadowRadius)
        .animate(_choicesAnimationController)
          ..addListener(() {
            setState(() {});
          });

    _timerAnimationController = AnimationController(
        duration: Duration(seconds: widget.question.timer), vsync: this);
    _timerAnimation =
        Tween(begin: 1.0, end: 0.0).animate(_timerAnimationController)
          ..addListener(() {
            setState(() {
              // the state that has changed here is the animation object’s value
              timeLeft = (_timerAnimation.value * widget.question.timer).ceil();
            });
          });
    _timerAnimationController.forward().then((value) {
      if (markedAnswer == null) {
        widget.onEnd('timeout');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timerAnimationController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: Duration(milliseconds: 300),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 15),
              child: Container(
                child: SizedBox(
                  height: 30,
                  child: LinearPercentIndicator(
                    lineHeight: 25.0,
                    percent: _timerAnimation.value,
                    center: Text(
                      '$timeLeft s',
                      style: new TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 17.0,
                        color: _timerAnimation.value >= 0.45
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    backgroundColor: customBlue[1],
                    progressColor: limeYellow,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
//                        height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: customBlue[2],
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question',
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 17,
                                color: limeYellow,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              widget.question.statement,
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 15,
                              ),
                            ),
                            widget.question.imageUrl == null
                                ? Container()
                                : Divider(
                                    color: customBlue[1],
                                    height: 30,
                                    thickness: 1,
                                  ),
                            widget.question.imageUrl == null
                                ? Container()
                                : Center(
                                    child: LimitedBox(
                                        maxHeight: 300,
                                        child: Image.network(
                                            widget.question.imageUrl)),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
                    child: Container(
//                        height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: customBlue[2],
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choices',
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 17,
                                color: limeYellow,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: widget.question.choices
                                  .asMap()
                                  .map((i, e) {
                                    BoxShadow boxShadow;
                                    Color textColor = Colors.white;
                                    if (markedAnswer != null) {
                                      if (i == widget.question.answer) {
                                        textColor = Colors.black;
                                        boxShadow = BoxShadow(
                                            color: Color.fromARGB(
                                                ((1 -
                                                            _choicesAnimation
                                                                    .value /
                                                                maxShadowRadius) *
                                                        255)
                                                    .floor(),
                                                139,
                                                195,
                                                74),
                                            blurRadius: _choicesAnimation.value,
                                            spreadRadius:
                                                _choicesAnimation.value);
                                      } else if (i == markedAnswer) {
                                        boxShadow = BoxShadow(
                                            color: Color.fromARGB(
                                                ((1 -
                                                            _choicesAnimation
                                                                    .value /
                                                                maxShadowRadius) *
                                                        255)
                                                    .floor(),
                                                255,
                                                82,
                                                82),
                                            blurRadius: _choicesAnimation.value,
                                            spreadRadius:
                                                _choicesAnimation.value);
                                      }
                                    }
                                    return MapEntry(
                                      i,
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 12.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (markedAnswer == null) {
                                              setState(() {
                                                markedAnswer = i;
                                                _choicesAnimationController
                                                    .forward()
                                                    .then((value) =>
                                                        Future.delayed(
                                                            widget.stayDuration,
                                                            () {
                                                          widget.onEnd(
                                                              markedAnswer ==
                                                                      widget
                                                                          .question
                                                                          .answer
                                                                  ? 'correct'
                                                                  : 'incorrect');
                                                        }));
                                              });
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: markedAnswer == null
                                                  ? customBlue[1]
                                                  : (widget.question.answer == i
                                                      ? Colors.lightGreenAccent
                                                      : (markedAnswer == i
                                                          ? Colors.redAccent
                                                          : customBlue[1])),
                                              boxShadow: boxShadow == null
                                                  ? null
                                                  : [boxShadow],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Text(
                                                e,
                                                style: TextStyle(
                                                    fontFamily: 'Prompt',
                                                    fontSize: 15.0,
                                                    color: textColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                                  .values
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
