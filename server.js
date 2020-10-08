import { createRequire } from "module";
const require = createRequire(import.meta.url);
var WebSocketServer = require('websocket').server;
var http = require('http');
import {User, Room, Users, Rooms, WebSocketConnection, randomString} from './utils.js';

Rooms.addRoom(new Room('room1', 'fn9f', 'private', 9, [0, 1, 2]));
Rooms.addRoom(new Room('room2', 'dlkn8', 'public', 8, [3, 4]));

var server = http.createServer(function(request, response) {
  // process HTTP request. Since we're writing just WebSockets
  // server we don't have to implement anything.
});
server.listen(1337, function() { });

// create the server
var wsServer = new WebSocketServer({
  httpServer: server
});

// WebSocket server
wsServer.on('request', function(request) {
  var connection = request.accept(null, request.origin);
  var wsConnection = new WebSocketConnection(connection);
  var user;

  wsConnection.sendMessage('status', 'success');

  wsConnection.addListener('username', function (message) {
    user = new User(message, wsConnection);
    if(Users.addUser(user)) {
      wsConnection.sendMessage('username', 'success');
    } else {
      wsConnection.sendMessage('username', 'failure');
    }
  });

  wsConnection.addListener('get_room', function(message) {
    if(message === 'all') {
      wsConnection.sendMessage('get_room', Rooms.getAll(false));
    }
  });

  wsConnection.addListener('add_room', function(message) {
    var newRoom = new Room(message.name, randomString(7), message.access, message.maxSize, [user.userId]);
    if(Rooms.addRoom(newRoom)) {
      wsConnection.sendMessage('add_room', {status: 'success', room: newRoom});
      Users.broadcastMessage('update_rooms', Rooms.getAll(false));
    } else {
      wsConnection.sendMessage('add_room', {status: 'failure', error: 'Room name is taken'});
    }
  });
  
  // This is the most important callback for us, we'll handle
  // all messages from users here.
  connection.on('message', function(message) {
    if(message.type === 'utf8') {
        var msgData = JSON.parse(message.utf8Data);
        wsConnection.handleEvent(msgData.type, msgData.message);
    }
  });

  connection.on('close', function(connection) {
    // close user connection
    Rooms.removeUserFromRoom(user);
    Users.removeUser(user);
    Users.broadcastMessage('update_rooms', Rooms.getAll(false));
  });
});