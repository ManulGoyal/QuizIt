import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quizit/quiz_management.dart';
import 'package:quizit/utilities.dart';
import 'package:quizit/web_socket_connection.dart';
import 'package:quizit/custom_widgets.dart';
import 'package:quizit/question_display.dart';
import 'dart:async';
import 'dart:math';
import 'package:percent_indicator/percent_indicator.dart';

class PlayQuiz extends StatefulWidget {
  final WebSocketConnection connection;
  final int roomId;

  PlayQuiz({@required this.connection, @required this.roomId});

  @override
  _PlayQuizState createState() => _PlayQuizState();
}

class _PlayQuizState extends State<PlayQuiz> {
  Quiz quiz;
  Widget currentWidget = Container();
  List<int> correctAnswers = new List<int>();
  List<int> incorrectAnswers = new List<int>();
  List<int> timeouts = new List<int>();
//  int current = 0;
//  List<Widget> widgets = [Container()];

  @override
  void initState() {
    widget.connection.addListener('get_quiz', (msg) {
      if (msg['status'] == 'success') {
        setState(() {
          quiz = Quiz.fromJSON(msg['quiz']);
          currentWidget = getNextQuestionCounter(0);
        });
      } else {
        print(msg['error']);
      }
    });

    widget.connection.sendMessage('get_quiz', null);

//    for (int i = 1; i <= 3; i++) {
//      widgets.add(AnimatedQuestionCounter(
//          child: Container(
//            child: Text(
//              '$i',
//              style: TextStyle(
//                fontFamily: 'Acme',
//                fontSize: 50,
//              ),
//            ),
//          ),
//          slideDuration: Duration(milliseconds: 500),
//          stayDuration: Duration(seconds: 2),
//          onEnd: () {
//            setState(() {
//              current += 1;
//            });
//          }));
//    }
//    setState(() {
//      current += 1;
//    });

//    widgets.add(AnimatedQuestionCounter(
//        key: UniqueKey(),
//        child: Container(
//          child: Text(
//            '1',
//            style: TextStyle(
//              fontFamily: 'Acme',
//              fontSize: 50,
//            ),
//          ),
//        ),
//        slideDuration: Duration(milliseconds: 500),
//        stayDuration: Duration(seconds: 2),
//        onEnd: () {
//          widgets.add(AnimatedQuestionCounter(
//              key: UniqueKey(),
//              child: Container(
//                child: Text(
//                  '2',
//                  style: TextStyle(
//                    fontFamily: 'Acme',
//                    fontSize: 50,
//                  ),
//                ),
//              ),
//              slideDuration: Duration(milliseconds: 500),
//              stayDuration: Duration(seconds: 2),
//              onEnd: () {}));
//          setState(() {
//            current += 1;
//          });
//        }));
//    setState(() {
//      current += 1;
//    });

    super.initState();
  }

  Widget getNextQuestionCounter(int i) {
    return i >= quiz.questions.length
        ? Container()
        : AnimatedQuestionCounter(
            key: UniqueKey(),
            child: Container(
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontFamily: 'Acme',
                  fontSize: 50,
                ),
              ),
            ),
            slideDuration: Duration(milliseconds: 500),
            stayDuration: Duration(seconds: 2),
            onEnd: () {
              setState(() {
                currentWidget = getNextQuestionDisplay(i);
              });
            });
  }

  Widget getNextQuestionDisplay(int i) {
    return QuestionDisplay(
      key: UniqueKey(),
      question: quiz.questions[i],
      stayDuration: Duration(seconds: 2),
      onEnd: (result) {
        if (result == 'timeout') {
          timeouts.add(i);
        } else if (result == 'correct') {
          correctAnswers.add(i);
        } else {
          incorrectAnswers.add(i);
        }
        setState(() {
          currentWidget = getNextResultDisplay(i, result);
        });
      },
    );
  }

  Widget getNextResultDisplay(int i, String result) {
    return AnimatedQuestionCounter(
        key: UniqueKey(),
        child: Container(
          child: Text(
            result.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Acme',
              fontSize: 50,
            ),
          ),
        ),
        slideDuration: Duration(milliseconds: 500),
        stayDuration: Duration(seconds: 2),
        onEnd: () {
          setState(() {
            currentWidget = getNextQuestionCounter(i + 1);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: Text(
        quiz == null ? "" : quiz.topic,
        style: TextStyle(fontFamily: 'Acme', fontSize: 30),
      ),
      body: quiz == null
          ? Center(child: CircularProgressIndicator(value: null))
          : currentWidget,
    );
  }
}
