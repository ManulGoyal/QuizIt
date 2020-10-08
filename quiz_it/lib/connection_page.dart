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

/* The main widget which defines the connection page that the user sees */
class ConnectionPage extends StatefulWidget {
  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  TextEditingController _ipController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();

  void connectToServer() {
    String ip = _ipController.text;
    String name = _nameController.text;
    connection.connect(ip, () {
      showToast("Invalid IP address");
    });
    connection.addListener('status', (msg) {
      if (msg == 'failure') {
        showToast('Unable to connect to $ip');
      }
    });
    connection.addListener('username', (msg) {
      if (msg == 'success') {
        showToast('Successfully connected to $ip');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomManagementPage(connection: connection),
          ),
        );
      } else {
        showToast('Username $name already taken');
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Connect to Server',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Acme',
                    fontSize: 35,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  hintText: "Server IP",
                  icon: Icons.language,
                  controller: _ipController,
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  hintText: "Your Name",
                  icon: Icons.person,
                  controller: _nameController,
                ),
                SizedBox(
                  height: 20,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.white)),
                  onPressed: connectToServer,
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Connect',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
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
