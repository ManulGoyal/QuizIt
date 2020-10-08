import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quizit/utilities.dart';
import 'package:quizit/web_socket_connection.dart';
import 'package:quizit/custom_widgets.dart';

final int minRoomSize = 2;
final int maxRoomSize = 10;

class RoomManagementPage extends StatefulWidget {
  final WebSocketConnection connection;
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
    widget.connection.addListener('get_room', (msg) {
      print(msg);

      List<dynamic> retrievedRooms =
          msg.map((room) => Room.fromJSON(room)).toList();
      setState(() {
        rooms = retrievedRooms.cast<Room>();
      });
    });
    widget.connection.addListener('update_rooms', (msg) {
      print(msg);

      List<dynamic> retrievedRooms =
          msg.map((room) => Room.fromJSON(room)).toList();
      setState(() {
        rooms = retrievedRooms.cast<Room>();
      });
    });
    widget.connection.addListener('add_room', (msg) {
      print(msg);
      switch (msg['status']) {
        case 'success':
          showToast('Room ${msg['room']['name']} created successfully');
          break;
        case 'failure':
          showToast(msg['error']);
          break;
      }
    });
    refreshRoomList();
    super.initState();
  }

  Future<void> refreshRoomList() async {
    widget.connection.sendMessage('get_room', 'all');
  }

  void createRoom(String name, String access, int maxSize) {
    widget.connection.sendMessage('add_room',
        {'name': name, 'access': access.toLowerCase(), 'maxSize': maxSize});
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
                    gradient: LinearGradient(
                        colors: [Color(0xFF2B3443), Color(0xFF5C677B)]),
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
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side: BorderSide(color: Colors.white)),
                                    onPressed: () {
                                      createRoom(_nameController.text,
                                          accessValue, maxParticipantsValue);
                                    },
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        'Create',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
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

  @override
  Widget build(BuildContext context) {
    print(rooms.length);
    return Scaffold(
      body: Column(
        children: [
          GradientAppBar(
            gradient:
                LinearGradient(colors: [Color(0xFF2B3443), Color(0xFF5C677B)]),
            child: Text(
              'Public Rooms',
              style: TextStyle(
                  fontFamily: 'Acme',
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF181E2C),
                    Color(0xFF444B5B),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: refreshRoomList,
                      child: ListView.builder(
// scrollDirection: Axis.horizontal,
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
//                              decoration: BoxDecoration(
//                                borderRadius: BorderRadius.circular(15.0),
//                              ),
//                        height: 220,
                              width: double.maxFinite,
                              child: Card(
                                elevation: 10,
                                child: Container(
                                  decoration: BoxDecoration(
//                                    borderRadius: BorderRadius.circular(10),
//                              border: Border(
//                                top: BorderSide(
//                                  width: 2.0,
//                                  color: Colors.green,
//                                ),
                                    gradient: LinearGradient(colors: [
                                      Color(0xFF2B3443),
                                      Color(0xFF5C677B)
                                    ]),
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: ListTile(
                                      leading: Icon(
                                        rooms[index].participants.length == 1
                                            ? Icons.person
                                            : Icons.people,
                                        size: 35,
                                      ),
                                      title: Text(rooms[index].name),
                                      subtitle: Text(
                                        'Participants: ${rooms[index].participants.length} / ${rooms[index].maxSize}',
                                        style:
                                            TextStyle(color: Color(0xFFFFF34F)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showCreateRoomDialog(context);
        },
      ),
    );
  }
}
