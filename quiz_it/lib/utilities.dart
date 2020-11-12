import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:quizit/connection_page.dart';

final List<Color> customBlue = [
  Color(0xFF757190),
  Color(0xFF3B3850),
  Color(0xFF23212E),
  Color(0xFF16141C)
];
final Color limeYellow = Color(0xFFFFF34F);

/* A utility function to conveniently show toasts. */
void showToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.black,
      fontSize: 16.0);
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class User {
  int userId;
  String username;

  User({@required this.userId, @required this.username});
  factory User.fromJSON(Map<String, dynamic> user) {
    return User(userId: user['userId'], username: user['username']);
  }
}

enum RoomAccess { PUBLIC, PRIVATE }

class Room {
  int id;
  String name;
  String code;
  RoomAccess access;
  int maxSize;
  int host;
  List<int> participants;
  String quizTopic;
  int quizLength;

  Room(
      {@required this.id,
      @required this.name,
      @required this.code,
      @required this.access,
      @required this.maxSize,
      @required this.host,
      @required this.participants,
      @required this.quizTopic,
      @required this.quizLength});

  factory Room.fromJSON(Map<String, dynamic> room) {
    return Room(
        id: room['id'],
        name: room['name'],
        code: room['code'],
        access: room['access'] == 'private'
            ? RoomAccess.PRIVATE
            : RoomAccess.PUBLIC,
        maxSize: room['maxSize'],
        host: room['host'],
        participants: room['participants'].cast<int>(),
        quizTopic: room['quiz_topic'],
        quizLength: room['quiz_length']);
  }
}

class QuizQuestion {
  String statement;
  String imageUrl;
  List<String> choices;

  QuizQuestion(
      {@required this.statement,
      @required this.imageUrl,
      @required this.choices});

  factory QuizQuestion.fromJSON(Map<String, dynamic> question) {
    return QuizQuestion(
        statement: question['statement'],
        imageUrl: question['imageUrl'],
        choices: question['choices'].cast<String>());
  }

  @override
  String toString() {
    return 'Statement: ${this.statement}, image: ${this.imageUrl}, choices: ${this.choices}';
  }

  Map<String, dynamic> toJson() {
    return {
      'statement': this.statement,
      'image_url': this.imageUrl,
      'choices': this.choices,
    };
  }
}

class Quiz {
  String topic;
  List<QuizQuestion> questions = new List<QuizQuestion>();

  Quiz();

  factory Quiz.fromJSON(Map<String, dynamic> quizJson) {
    List<dynamic> questions = quizJson['questions'];
    Quiz quiz = new Quiz();
    quiz.topic = quizJson['topic'];
    questions.forEach((question) {
      quiz.questions.add(QuizQuestion.fromJSON(question));
    });

    return quiz;
  }

  @override
  String toString() {
    return 'Topic: ${this.topic}, Questions: ${this.questions.map((e) => e.toString()).toList()}';
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': this.topic,
      'questions': this.questions,
    };
  }
}
