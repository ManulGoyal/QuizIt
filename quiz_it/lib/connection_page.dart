import 'package:flutter/material.dart';
import 'web_socket_connection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'utilities.dart';

final WebSocketConnection connection = new WebSocketConnection();

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  CustomTextField(
      {@required this.hintText,
      @required this.icon,
      @required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        this.icon,
        color: Colors.white,
        size: 30,
      ),
      title: TextField(
        controller: this.controller,
        decoration: new InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(20.0),
            ),
            borderSide: BorderSide(
              color: Colors.white,
              width: 1,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(20.0),
            ),
            borderSide: BorderSide(
              color: Colors.white,
              width: 1,
            ),
          ),
          filled: true,
          hintStyle: TextStyle(color: Colors.white),
          hintText: this.hintText,
        ),
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}

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
                  icon: Icons.web,
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
