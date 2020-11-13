import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quizit/play_quiz.dart';
import 'package:quizit/quiz_management.dart';
import 'package:quizit/utilities.dart';
import 'package:quizit/web_socket_connection.dart';
import 'package:quizit/custom_widgets.dart';
import 'package:quizit/question_display.dart';
import 'dart:async';

final String publicRoomDescription =
    "This is a public room, which is visible to everyone (anyone can join the room). Alternatively, you may share the invite code above to your friends to invite them to this room.";
final String privateRoomDescription =
    "This is a private room, which is only visible to the participants. Share the invite code above with your friends to invite them to this room!";

class RoomDetailsPage extends StatefulWidget {
  final int roomId;
  final WebSocketConnection connection;
  final List<PopupMenuChoice> choices = [
    PopupMenuChoice(0, Icon(Icons.edit), "Create/modify quiz"),
    PopupMenuChoice(1, Icon(Icons.play_arrow), "Start quiz")
  ];

  RoomDetailsPage({@required this.connection, @required this.roomId});

  @override
  _RoomDetailsPageState createState() => _RoomDetailsPageState();
}

class _RoomDetailsPageState extends State<RoomDetailsPage> {
  Room room;
  List<User> participants = new List<User>();

  @override
  void initState() {
    widget.connection.addListener('get_room_by_id', (msg) {
      if (msg['status'] == 'success') {
        Room retrievedRoom = Room.fromJSON(msg['room']);
        if (retrievedRoom.participants
            .contains(widget.connection.user.userId)) {
          List<User> retrievedParticipants = msg['participants']
              .map((participant) => User.fromJSON(participant))
              .toList()
              .cast<User>();
//          participants.forEach((participant) {
//            if (!retrievedParticipants.contains(participant)) {
//              showToast('${participant.username} has left the room');
//            }
//          });
//          retrievedParticipants.forEach((participant) {
//            if (!participants.contains(participant)) {
//              showToast('${participant.username} has joined the room');
//            }
//          });
          setState(() {
            room = retrievedRoom;
            participants = retrievedParticipants;
          });
        } else {
          print('Error: user not in room');
        }
      } else {
        print(msg['error']);
        showToast("Room ${room.name} has been disbanded");
        if (room.host != widget.connection.user.userId) {
          Navigator.pop(context);
        }
      }
    });
    widget.connection.addListener('remove_from_room', (msg) {
      if (msg['status'] == 'success') {
//        if (widget.connection.user.userId == room.host) {
//          print("host removed room");
////          showToast('Room ${room.name} disbanded');
//        } else {
        print("to remove");
        if (msg['origin'] == 'self') {
          showToast('Left room ${room.name}');
        } else if (msg['origin'] == 'host') {
          showToast('You have been kicked from the room');
          Navigator.pop(context);
        }
//        }
      } else {
        print(msg['error']);
      }
    });
    widget.connection.addListener('remove_user_from_room', (msg) {
      if (msg['status'] == 'success') {
        showToast('User kicked from room');
      } else {
        print(msg['error']);
      }
    });
    widget.connection.addListener('update_rooms', (msg) {
      refreshRoom();
    });
    widget.connection.addListener('start_quiz', (msg) {
      if (msg['status'] == 'success') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlayQuiz(
                    connection: widget.connection, roomId: widget.roomId)));
      }
    });
    refreshRoom();
    super.initState();
  }

  Future<void> refreshRoom() async {
    widget.connection.sendMessage('get_room_by_id', widget.roomId);
  }

  String getUserDisplay(int index) {
    if (participants[index].userId == widget.connection.user.userId) {
      return participants[index].username + ' (You)';
    } else {
      return participants[index].username;
    }
  }

  Widget getUserInfo(int index) {
    if (room.host == participants[index].userId) {
      return Text(
        'Host',
      );
    } else {
      if (room.host == widget.connection.user.userId) {
        return GestureDetector(
          onTap: () {
            widget.connection.sendMessage(
                'remove_user_from_room', participants[index].userId);
          },
          child: Icon(Icons.close),
        );
      } else {
        return Container(
          width: 0,
          height: 0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return room == null
        ? Container()
        : WillPopScope(
            onWillPop: () async {
              return await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Container(
                        decoration: BoxDecoration(
//                    gradient: LinearGradient(
//                        colors: [Color(0xFF2B3443), Color(0xFF5C677B)]),
                          color: customBlue[1],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 190,
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  'Do you want to leave the room?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Prompt',
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomButton(
                                    text: 'Yes',
                                    onPressed: () {
                                      widget.connection.sendMessage(
                                          'remove_from_room', null);
                                      Navigator.pop(context, true);
                                    },
                                  ),
                                  CustomButton(
                                    text: 'No',
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            },
            child: CustomScaffold(
              title: Text(
                'Personal Room',
                style: TextStyle(fontFamily: 'Acme', fontSize: 30),
              ),
              body: Expanded(
                child: RefreshIndicator(
                  onRefresh: refreshRoom,
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0, bottom: 8.0),
                        child: Container(
//                        height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: customBlue[2],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                10.0, 20.0, 10.0, 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(
                                    room.name,
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 25,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Invite Code: ${room.code}',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  trailing: RoomIcon(
                                    room: room,
                                    width: 50,
                                    height: 50,
                                    fontSize: 30,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                  ),
                                  child: Divider(
                                    color: customBlue[1],
                                    thickness: 1,
                                    height: 30,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12.0,
                                    right: 12.0,
                                  ),
                                  child: Text(
                                    room.access == RoomAccess.PRIVATE
                                        ? privateRoomDescription
                                        : publicRoomDescription,
                                    style: TextStyle(fontFamily: 'Prompt'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: customBlue[2],
                          ),
                          height: 300,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                22.0, 20.0, 22.0, 20.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Participants',
                                        style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        '${room.participants.length} / ${room.maxSize}',
                                        style: TextStyle(
                                          color: limeYellow,
                                          fontFamily: 'Prompt',
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: customBlue[1],
//                                  height: 20,
                                  thickness: 1,
                                ),
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: participants.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4.0,
                                            bottom: 4.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                getUserDisplay(index),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontFamily: 'Prompt'),
                                              ),
                                              getUserInfo(index),
                                            ],
                                          ),
                                        );
                                      }),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              fab: widget.connection.user.userId == room.host,
              choices: widget.choices,
              onSelected: (choice) {
                switch (choice.choiceId) {
                  case 0:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QuizManagement(
                                  connection: widget.connection,
                                  roomId: widget.roomId,
                                )));
//            refreshRoomList();
                    break;
                  case 1:
                    widget.connection.sendMessage('start_quiz', null);
                    break;
                }
              },
            ),
          );
  }
}
