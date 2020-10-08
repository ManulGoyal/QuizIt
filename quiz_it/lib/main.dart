/* This is the main file, where the app execution begins. It renders the
 * ConnectionPage as soon as it loads, which the user uses to connect to
 * an IP address and choose his/her username.
 */

import 'package:flutter/material.dart';
import 'package:quizit/room_management_page.dart';
import 'package:quizit/connection_page.dart';

import 'package:quizit/web_socket_connection.dart';

final String title = "QuizIt";

void main() => runApp(MyApp());

//WebSocketConnection con = new WebSocketConnection();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    con.connect('ws://10.0.2.2:1337', () {
//      print("errorr");
//    });
    return MaterialApp(
      title: title,
      theme: ThemeData.dark(),
      initialRoute: '/connection_page',
      routes: {
        '/connection_page': (context) => ConnectionPage(),
//        '/room_management_page': (context) =>
//            RoomManagementPage(connection: con),
      },
    );
  }
}
