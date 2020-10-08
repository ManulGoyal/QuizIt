import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'dart:math';

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
  List<int> participants;

  Room(
      {@required this.id,
      @required this.name,
      @required this.code,
      @required this.access,
      @required this.maxSize,
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
        participants: room['participants'].cast<int>());
  }
}
