import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quizit/quiz_management.dart';
import 'package:quizit/utilities.dart';
import 'package:quizit/web_socket_connection.dart';
import 'package:quizit/custom_widgets.dart';
import 'package:quizit/question_display.dart';
import 'package:quizit/play_quiz.dart';
import 'dart:async';
import 'dart:math';
import 'package:percent_indicator/percent_indicator.dart';

final int maxUsernameLength = 15;

class Scoreboard extends StatefulWidget {
  final WebSocketConnection connection;

  // although roomId is not currently required by this widget, if the need
  // arises, you should request for the room using roomId and implement
  // 'update_rooms' handler
  final int roomId;
  final Map<String, dynamic> scores;

  Scoreboard(
      {Key key,
      @required this.connection,
      @required this.roomId,
      @required this.scores})
      : super(key: key);

  @override
  _ScoreboardState createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard> {
  List<Map<String, dynamic>> rankList;

  @override
  void initState() {
    super.initState();

    widget.connection.addListener('start_quiz', (msg) {
      if (msg['status'] == 'success') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlayQuiz(
                    connection: widget.connection, roomId: widget.roomId)));
      }
    });

    List<String> sortedUserIds = new List<String>();
    int currentRank;
    int prevScore = 1000000;
    int currentIndex = 1;

    sortedUserIds = widget.scores.keys.toList();
    print(widget.scores);
    print(
        widget.scores['${widget.connection.user.userId}']['score']['correct']);
    sortedUserIds.sort((id1, id2) {
      return -(widget.scores[id1]['score']['correct'].length
          .compareTo(widget.scores[id2]['score']['correct'].length));
    });

    rankList = sortedUserIds.map((id) {
      if (widget.scores[id]['score']['correct'].length < prevScore) {
        currentRank = currentIndex;
      }
      currentIndex++;
      prevScore = widget.scores[id]['score']['correct'].length;
      return {
        'userId': id,
        'rank': currentRank,
        'username': widget.scores[id]['username'],
        'score': widget.scores[id]['score']['correct'].length
      };
    }).toList();
  }

  @override
  void dispose() {
    print('Scoreboard disp');
    // widget.connection.clearListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: customBlue[2],
              ),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rank',
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 17,
                            color: limeYellow,
                          ),
                        ),
                        Text(
                          'Username',
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 17,
                            color: limeYellow,
                          ),
                        ),
                        Text(
                          'Score',
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 17,
                            color: limeYellow,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: customBlue[1],
                      height: 30,
                      thickness: 1,
                    ),
                    ...(rankList.map((row) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${row['rank']}',
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 17,
                                fontWeight: widget.connection.user.userId ==
                                        int.parse(row['userId'])
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              '${row['username'].length > maxUsernameLength ? row['username'].substring(0, maxUsernameLength) + '...' : row['username']}',
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 17,
                                fontWeight: widget.connection.user.userId ==
                                        int.parse(row['userId'])
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontStyle: widget.connection.user.userId ==
                                        int.parse(row['userId'])
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                            Text(
                              '${row['score']}',
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 17,
                                fontWeight: widget.connection.user.userId ==
                                        int.parse(row['userId'])
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()),
                    // ...(List<int>.generate(100, (i) => i + 1).map((element) {
                    //   return Padding(
                    //     padding: const EdgeInsets.only(bottom: 8.0),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         Text(
                    //           '6',
                    //           style: TextStyle(
                    //             fontFamily: 'Prompt',
                    //             fontSize: 17,
                    //           ),
                    //         ),
                    //         Text(
                    //           '${'manul goyal manul goyal'.length > 15 ? 'manul goyal manul goyal'.substring(0, 15) + '...' : 'manul goyal manul goyal'}',
                    //           style: TextStyle(
                    //             fontFamily: 'Prompt',
                    //             fontSize: 17,
                    //             fontWeight: FontWeight.bold,
                    //             // color: Colors.greenAccent,
                    //             // fontStyle: FontStyle.italic,
                    //           ),
                    //         ),
                    //         Text(
                    //           '7',
                    //           style: TextStyle(
                    //             fontFamily: 'Prompt',
                    //             fontSize: 17,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   );
                    // }).toList()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
