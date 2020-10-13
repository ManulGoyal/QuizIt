/* This file defines a class WebSocketConnection which abstracts out
 * the details of handling the WebSocketChannel.
 */

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'package:quizit/utilities.dart';

class WebSocketConnection {
  WebSocketChannel channel;
  User user;
  Map<String, Function> eventListener = new Map<String, Function>();

  /* This function is used to connect to the given IP address. Any previous
   * connection is disconnected and the new connection is established, and
   * in case of an exception, the callback handleException is invoked.
   */
  void connect(String ip, Function handleException) {
    try {
      channel?.sink?.close();
      channel =
          IOWebSocketChannel.connect(ip, pingInterval: Duration(seconds: 2));
      channel.stream.listen((message) {
        print(message);
        Map<String, dynamic> msgData = jsonDecode(message);
        if (eventListener.containsKey(msgData['type'])) {
          eventListener[msgData['type']](msgData['message']);
        }
      });
    } catch (e) {
      print(e);
      handleException('Invalid IP address');
    }
  }

  /* This function is used to add event listeners for different events. */
  void addListener(String event, Function listener) {
    eventListener[event] = listener;
  }

  /* This function is used to send a message, which is handled by the server. */
  void sendMessage(String type, dynamic message) {
    channel?.sink?.add(jsonEncode({'type': type, 'message': message}));
  }
}
