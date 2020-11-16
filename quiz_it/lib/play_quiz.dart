import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quizit/quiz_management.dart';
import 'package:quizit/scoreboard.dart';
import 'package:quizit/utilities.dart';
import 'package:quizit/web_socket_connection.dart';
import 'package:quizit/custom_widgets.dart';
import 'package:quizit/question_display.dart';
import 'dart:async';
import 'dart:math';
import 'package:percent_indicator/percent_indicator.dart';

class PlayQuiz extends StatefulWidget {
  final WebSocketConnection connection;

  // although roomId is not currently required by this widget, if the need
  // arises, you should request for the room using roomId and implement
  // 'update_rooms' handler
  final int roomId;

  PlayQuiz({@required this.connection, @required this.roomId});

  @override
  _PlayQuizState createState() => _PlayQuizState();
}

class _PlayQuizState extends State<PlayQuiz> {
  Quiz quiz;
  Widget currentWidget = Container();
  String title;
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
          title = "";
        });
      } else {
        print(msg['error']);
      }
    });

    widget.connection.addListener('end_quiz', (msg) {
      if (msg['status'] == 'success') {
        setState(() {
          currentWidget = getResultsIndicator(msg['scores']);
          title = "";
        });
      } else {
        print(msg['error']);
      }
    });

    widget.connection.sendMessage('get_quiz', null);

    super.initState();
  }

  Widget getResultsIndicator(Map<String, dynamic> scores) {
    return AnimatedQuestionCounter(
        key: UniqueKey(),
        child: Container(
          child: Text(
            'Time for Results!',
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
            currentWidget = Scoreboard(
                connection: widget.connection,
                roomId: widget.roomId,
                scores: scores);
            title = "Scoreboard";
          });
        });
  }

  Widget getNextQuestionCounter(int i) {
    if (i >= quiz.questions.length) {
      // user has finished the quiz, send his scores to server
      widget.connection.sendMessage('end_quiz', {
        'correct': correctAnswers,
        'incorrect': incorrectAnswers,
        'timeout': timeouts
      });
      print('SENTT');
    }
    return i >= quiz.questions.length
        ? Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 12.0,
                right: 12.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'Waiting for others to finish the quiz. Stay tuned for the results!',
                      style: TextStyle(fontFamily: 'Acme', fontSize: 30.0),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  CircularProgressIndicator(
                    value: null,
                  )
                ],
              ),
            ),
          )
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
                title = quiz.topic;
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
          title = "";
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
            title = "";
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: Text(
        quiz == null ? "" : title,
        style: TextStyle(fontFamily: 'Acme', fontSize: 30),
      ),
      body: quiz == null
          ? Center(child: CircularProgressIndicator(value: null))
          : currentWidget,
    );
  }
}
