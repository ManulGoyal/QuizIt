/* This file defines the first page the user sees, and it allows the user to
 * connect to an IP address and simultaneously choose a username, which will be
 * visible to the other users on the network.
 */

import 'package:flutter/material.dart';
import 'package:quizit/room_management_page.dart';
import 'package:quizit/web_socket_connection.dart';
import 'package:quizit/utilities.dart';
import 'package:quizit/custom_widgets.dart';

/* The connection object defined below is an instance of the custom class
 * WebSocketConnection, and is used to handle the websocket connection,
 * including adding event listeners.
 */
final WebSocketConnection connection = new WebSocketConnection();
final serverIP = 'ws://thequizit.herokuapp.com';

/* The main widget which defines the connection page that the user sees */
class ConnectionPage extends StatefulWidget {
  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  // TODO: remove defaults
  // TextEditingController _ipController =
  //     new TextEditingController(text: 'ws://10.0.2.2:8000');
  TextEditingController _nameController = new TextEditingController();

  void connectToServer() {
    // String ip = _ipController.text;
    String name = _nameController.text;
    connection.connect(serverIP, (String error) {
      showToast(error);
    });
    connection.addListener('status', (msg) {
      if (msg == 'failure') {
        showToast('Unable to connect to server');
      }
    });
    connection.addListener('username', (msg) {
      if (msg['status'] == 'success') {
        connection.user = new User(
          userId: msg['userId'],
          username: name,
        );
        showToast('Successfully connected to server');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomManagementPage(connection: connection),
            maintainState: false,
          ),
        );
      } else {
        showToast(msg['error']);
      }
    });
    connection.sendMessage('username', name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/openingWP.jfif'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo2.png'),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'QuizIt',
                        style: TextStyle(
                          fontFamily: 'Acme',
                          fontSize: 50.0,
                        ),
                      ),
                      // Text(
                      //   'Connect to Server',
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //     fontFamily: 'Acme',
                      //     fontSize: 35,
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 20,
                      // ),
                      // CustomTextField(
                      //   hintText: "Server IP",
                      //   icon: Icons.language,
                      //   controller: _ipController,
                      // ),
                      SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        hintText: "Your Name",
                        icon: Icons.person,
                        controller: _nameController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CustomButton(
                        text: 'Connect',
                        onPressed: connectToServer,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
