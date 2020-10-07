import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

class WebSocketConnection {
  WebSocketChannel channel;
  Map<String, Function> eventListener = new Map<String, Function>();

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
      handleException();
    }
  }

  void addListener(String event, Function listener) {
    eventListener[event] = listener;
  }

  void sendMessage(String type, String message) {
    channel?.sink?.add(jsonEncode({'type': type, 'message': message}));
  }
}
