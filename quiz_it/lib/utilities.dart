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

  Room(
      {@required this.id,
      @required this.name,
      @required this.code,
      @required this.access,
      @required this.maxSize,
      @required this.host,
      @required this.participants});
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
        participants: room['participants'].cast<int>());
  }
}
