/* This is the main file, where the app execution begins. It renders the
 * ConnectionPage as soon as it loads, which the user uses to connect to
 * an IP address and choose his/her username.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'connection_page.dart';

final String title = "QuizIt";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: SafeArea(
        child: ConnectionPage(),
      ),
    );
  }
}
