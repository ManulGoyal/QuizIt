import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quizit/connection_page.dart';
import 'package:quizit/room_details_page.dart';
import 'package:quizit/utilities.dart';
import 'package:quizit/web_socket_connection.dart';
import 'package:quizit/custom_widgets.dart';
import 'package:flutter/foundation.dart';

final int minRoomSize = 2;
final int maxRoomSize = 10;

class RoomManagementPage extends StatefulWidget {
  final WebSocketConnection connection;
  final List<PopupMenuChoice> choices = [
    PopupMenuChoice(0, Icon(Icons.add), "Create a room"),
    PopupMenuChoice(1, Icon(Icons.code), "Join using code")
  ];
  RoomManagementPage({@required this.connection});

  @override
  _RoomManagementPageState createState() => _RoomManagementPageState();
}

class _RoomManagementPageState extends State<RoomManagementPage> {
  List<Room> rooms = new List<Room>();

  @override
  void initState() {
//    const refreshInterval = const Duration(seconds: 5);
//    Timer.periodic(refreshInterval, (Timer t) => refreshRoomList());

    widget.connection.addListener('get_rooms_all', (msg) {
      print(msg);

      List<dynamic> retrievedRooms =
          msg.map((room) => Room.fromJSON(room)).toList();
      setState(() {
        rooms = retrievedRooms.cast<Room>();
      });
    });

    widget.connection.addListener('update_rooms', (msg) {
      refreshRoomList();
    });
    refreshRoomList();
    super.initState();
  }

  Future<void> refreshRoomList() async {
    widget.connection.sendMessage('get_rooms_all', null);
  }

  void createRoom(
      BuildContext context, String name, String access, int maxSize) {
    widget.connection.sendMessage('add_room',
        {'name': name, 'access': access.toLowerCase(), 'maxSize': maxSize});
    widget.connection.addListener('add_room', (msg) {
      print(msg);
//      Room room = Room.fromJSON(msg['room']);
      switch (msg['status']) {
        case 'success':
          showToast('Room $name created successfully');
//          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RoomDetailsPage(
                connection: widget.connection,
                roomId: msg['room_id'],
              ),
            ),
          );
//          Navigator.pop(context);
          break;
        case 'failure':
          showToast(msg['error']);
          break;
      }
    });
  }

  void addToRoom(BuildContext context, Room room, {bool usingCode = false}) {
    widget.connection.sendMessage('add_to_room', room.id);
    widget.connection.addListener('add_to_room', (msg) {
      print(msg);
      print("context: ");
      print(context);
//      Room room = Room.fromJSON(msg['room']);
      if (msg['status'] == 'success') {
        showToast('Joined room ${room.name}');
        Function pushScreen =
            usingCode ? Navigator.pushReplacement : Navigator.push;
        pushScreen(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailsPage(
              connection: widget.connection,
              roomId: room.id,
            ),
          ),
        );
      } else {
        if (room.participants.length >= room.maxSize) {
          showToast('Room already full');
        } else {
          showToast('Cannot join room');
        }
      }
    });
  }

  void joinUsingCode(BuildContext context, String inviteCode) {
    widget.connection.sendMessage('get_room_by_code', inviteCode);
    widget.connection.addListener('get_room_by_code', (msg) {
      if (msg['status'] == 'success') {
        Room room = Room.fromJSON(msg['room']);
        addToRoom(context, room, usingCode: true);
      } else {
        showToast(msg['error']);
      }
    });
  }

  void showCreateRoomDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          String accessValue = 'Private';
          int maxParticipantsValue = 5;
          TextEditingController _nameController = new TextEditingController();
          return StatefulBuilder(
            builder: (context, setState) {
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
                  height: 350,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 18.0, 12.0, 18.0),
                    child: Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Create a Room',
                              style:
                                  TextStyle(fontSize: 25, fontFamily: 'Acme'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              CustomTextField(
                                controller: _nameController,
                                hintText: 'Room name',
                                icon: Icons.people,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 15, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Access',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    DropdownButton<String>(
                                      items: <String>['Private', 'Public']
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      value: accessValue,
                                      onChanged: (newValue) {
                                        setState(() {
                                          accessValue = newValue;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 15, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Max Participants',
                                      style: TextStyle(fontSize: 15),
                                    ),
//                                    NumberPicker.integer(
//                                      initialValue: maxParticipantsValue,
//                                      minValue: 2,
//                                      maxValue: 10,
//                                      onChanged: (newValue) {
//                                        setState(() {
//                                          maxParticipantsValue = newValue;
//                                        });
//                                      },
//                                    ),
                                    NumberSpinner(
                                      value: maxParticipantsValue,
                                      minValue: minRoomSize,
                                      maxValue: maxRoomSize,
                                      onChange: (newValue) {
                                        setState(() {
                                          maxParticipantsValue = newValue;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Center(
                                  child: CustomButton(
                                    text: 'Create',
                                    onPressed: () {
                                      createRoom(context, _nameController.text,
                                          accessValue, maxParticipantsValue);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  void showJoinUsingCodeDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          TextEditingController _codeController = new TextEditingController();
          return StatefulBuilder(
            builder: (context, setState) {
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
                  height: 250,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 18.0, 12.0, 18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Join using Invite Code',
                              style:
                                  TextStyle(fontSize: 25, fontFamily: 'Acme'),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        CustomTextField(
                          controller: _codeController,
                          hintText: 'Invite code',
                          icon: Icons.code,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Center(
                            child: CustomButton(
                              text: 'Join',
                              onPressed: () {
                                joinUsingCode(context, _codeController.text);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    print(context);
    print("manul");
    return CustomScaffold(
      title: Text(
        'Public Rooms',
        style: TextStyle(fontFamily: 'Acme', fontSize: 30),
      ),
      body: Expanded(
        child: RefreshIndicator(
          onRefresh: refreshRoomList,
          child: ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                  top: 6.0,
                  bottom: 6.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: customBlue[2],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        addToRoom(context, rooms[index]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(4.0, 10.0, 4.0, 10.0),
                          child: ListTile(
                            leading: RoomIcon(
                              room: rooms[index],
                              width: 50,
                              height: 50,
                              fontSize: 30,
                            ),
//                            leading: Container(
//                              width: 50,
//                              decoration: BoxDecoration(
//                                borderRadius: BorderRadius.circular(15.0),
//                                color: customBlue[1],
//                              ),
//                              child: Padding(
//                                padding: const EdgeInsets.all(8.0),
//                                child: Center(
//                                  child: Text(
//                                    '${rooms[index].name.substring(0, 1).toUpperCase()}',
//                                    style: TextStyle(
//                                      fontSize: 30,
//                                      fontFamily: 'Acme',
//                                      color: customBlue[0],
////                                      fontWeight: FontWeight.bold,
//                                    ),
//                                  ),
//                                ),
//                              ),
//                            ),
                            title: Text(
                              rooms[index].name,
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              'Participants: ${rooms[index].participants.length} / ${rooms[index].maxSize}',
                              style: TextStyle(
                                color: limeYellow,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Topic: ${rooms[index].quizTopic}',
                                  style: TextStyle(
                                    fontFamily: 'Prompt',
                                    fontSize: 15.0,
                                  ),
                                ),
                                Text(
                                  '${rooms[index].quizLength} questions',
                                  style: TextStyle(
                                    fontFamily: 'Prompt',
                                    fontSize: 15.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      fab: true,
      choices: widget.choices,
      onSelected: (choice) {
        switch (choice.choiceId) {
          case 0:
            showCreateRoomDialog(context);
//            refreshRoomList();
            break;
          case 1:
            showJoinUsingCodeDialog(context);
            break;
        }
      },
    );
  }
}
