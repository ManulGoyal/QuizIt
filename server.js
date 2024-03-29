import { createRequire } from "module";
const require = createRequire(import.meta.url);
var WebSocketServer = require('websocket').server;
var http = require('http');
import {User, Room, Users, Rooms, WebSocketConnection, randomString} from './utils.js';
import {Quiz, QuizQuestion} from './quiz_utils.js';
import { isError } from "util";

// Rooms.addRoom(new Room('room1', 'fn9f', 'private', 9, 0, [0, 1, 2]));
// Rooms.addRoom(new Room('room2', 'dlkn8', 'public', 8, 1, [3, 4]));

var port = process.env.PORT;
if (port == null || port == "") {
  port = 8000;
}

var server = http.createServer(function(request, response) {
  // process HTTP request. Since we're writing just WebSockets
  // server we don't have to implement anything.
});
server.listen(port, function() {
  console.log('Listening on port ' + port);
});

// create the server
var wsServer = new WebSocketServer({
  httpServer: server
});

// WebSocket server
wsServer.on('request', function(request) {
  var connection = request.accept(null, request.origin);
  var wsConnection = new WebSocketConnection(connection);
  var user;
  // var room = null;

  wsConnection.sendMessage('status', 'success');

  wsConnection.addListener('username', function (message) {
    user = new User(message, wsConnection);
    if(Users.addUser(user)) {
      wsConnection.sendMessage('username', {status: 'success', userId: user.userId});
    } else {
      wsConnection.sendMessage('username', {status: 'failure', error: 'Username already taken'});
    }
  });

  wsConnection.addListener('get_rooms_all', function(message) {
    wsConnection.sendMessage('get_rooms_all', Rooms.getAll(false));
  });

  wsConnection.addListener('get_room_by_id', function(message) {
    var room = Rooms.getById(message);
    // console.log(message);
    // console.log(room);
    // console.log(room.getParticipants());
    if(room) {
      wsConnection.sendMessage('get_room_by_id', {status: 'success', room: room.getQuizlessJSON(), participants: room.getParticipants()});
    } else {
      wsConnection.sendMessage('get_room_by_id', {status: 'failure', error: 'Room id doesn\'t exist'});
    }
  });

  wsConnection.addListener('add_room', function(message) {
    if(user.room !== null) {
      wsConnection.sendMessage('add_room', {status: 'failure', error: 'Cannot join more than one room'});
    } else {
      var newRoom = new Room(message.name, randomString(7), message.access, message.maxSize, user.userId, [user.userId]);
      if(Rooms.addRoom(newRoom)) {
        user.room = newRoom;
        wsConnection.sendMessage('add_room', {status: 'success', room_id: user.room.id});
        Users.broadcastMessage('update_rooms', null);
      } else {
        wsConnection.sendMessage('add_room', {status: 'failure', error: 'Room name is taken'});
      }
    }
  });
  
  wsConnection.addListener('add_to_room', function(message) {
    if(user.room !== null) {
      console.log('here1');
      wsConnection.sendMessage('add_to_room', {status: 'failure', error: 'Cannot join more than one room'});
    } else {
      if(Rooms.addUserToRoom(user.userId, message)) {
        user.room = Rooms.getById(message);
        wsConnection.sendMessage('add_to_room', {status: 'success'});
        Users.broadcastMessage('update_rooms', null);
      } else {
        console.log('here2');
        wsConnection.sendMessage('add_to_room', {status: 'failure', error: 'Error in adding user to room'});
      }
    }
  });

  wsConnection.addListener('remove_from_room', function (message) {
    if(user.room === null) {
      wsConnection.sendMessage('remove_from_room', {status: 'failure', error: 'User not in any room'});
    } else {
      // var roomId = user.room.id;
      // var participants = Rooms.getById(roomId).participants;
      if(Rooms.removeUserFromRoom(user.userId, user.room.id)) {
        user.room = null;
        // if(Rooms.getById(roomId) !== null) {
        wsConnection.sendMessage('remove_from_room', {status: 'success', origin: 'self'});
        // } else {
        //   participants.forEach(function (userId) {
        //     var participant = Users.getById(userId);
        //     participant.wsConnection.sendMessage('remove_from_room', {status: 'success', origin: 'room'});
        //   });
        // }
        Users.broadcastMessage('update_rooms', null);
      } else {
        wsConnection.sendMessage('remove_from_room', {status: 'failure', error: 'User not in room or room doesn\'t exist'});
      }
    }
  });

  wsConnection.addListener('remove_user_from_room', function (message) {
    if(user.room === null) {
      wsConnection.sendMessage('remove_user_from_room', {status: 'failure', error: 'User not in any room'});
    } else if (user.room.host !== user.userId) {
      wsConnection.sendMessage('remove_user_from_room', {status: 'failure', error: 'User is not host'});
    } else if (user.room.host === message) {
      wsConnection.sendMessage('remove_user_from_room', {status: 'failure', error: 'Host can\'t remove himself'});
    } else {
      if(Rooms.removeUserFromRoom(message, user.room.id)) {
        var userToRemove = Users.getById(message);
        wsConnection.sendMessage('remove_user_from_room', {status: 'success'});
        userToRemove.wsConnection.sendMessage('remove_from_room', {status: 'success', origin: 'host'});
        userToRemove.room = null;
        Users.broadcastMessage('update_rooms', null);
      } else {
        wsConnection.sendMessage('remove_user_from_room', {status: 'failure', error: 'User not in room or room doesn\'t exist'});
      }
    }
  });

  wsConnection.addListener('get_room_by_code', function (message) {
    var room = Rooms.getByCode(message);
    // console.log(message);
    // console.log(room);
    // console.log(room.getParticipants());
    if(room) {
      wsConnection.sendMessage('get_room_by_code', {status: 'success', room: room.getQuizlessJSON()});
    } else {
      wsConnection.sendMessage('get_room_by_code', {status: 'failure', error: 'Room with given code doesn\'t exist'});
    }
  });

  wsConnection.addListener('get_quiz', function (message) {

    if(user.room) {
      wsConnection.sendMessage('get_quiz', {status: 'success', quiz: user.room.quiz});
    } else {
      wsConnection.sendMessage('get_quiz', {status: 'failure', error: 'User hasn\'t joined any room'});
    }
  });

  wsConnection.addListener('update_quiz', function(message) {
    console.log(message);
    // message should be a Quiz object
    // the whole quiz is updated at once
    if(user.room.host !== user.userId) {
      wsConnection.sendMessage('update_quiz', {status: 'failure', error: 'User is not host'});
    } else {
      user.room.quiz = Quiz.fromJSON(message);
      wsConnection.sendMessage('update_quiz', {status: 'success'});
      Users.broadcastMessage('update_rooms', null);
    }
  });

  wsConnection.addListener('start_quiz', function (message) {
    if(user.room) {
      if(user.room.quiz.status !== 'idle') {
        wsConnection.sendMessage('start_quiz', {status: 'failure', error: 'Quiz is already running'});
      } else if(user.room.host == user.userId) {
        user.room.quiz.status = 'running';
        user.room.participants.forEach(participantId => {
          var participant = Users.getById(participantId);
          participant.wsConnection.sendMessage('start_quiz', {status: 'success'});
        });
        Users.broadcastMessage('update_rooms', null);
      } else {
        wsConnection.sendMessage('start_quiz', {status: 'failure', error: 'User is not host'});
      }
    } else {
      wsConnection.sendMessage('start_quiz', {status: 'failure', error: 'User is not in any room'});
    }
  });

  wsConnection.addListener('end_quiz', function (message) {
    // this message from a client signifies that his quiz has ended
    // message = {'correct': [..], 'incorrect': [..], 'timeout': [..]}
    console.log(message);
    if(user.room.quiz.status !== 'running') {
      wsConnection.sendMessage('end_quiz', {status: 'failure', error: 'Quiz is not running'});
    } else if(user.setQuizScore(message)) {
      console.log(user.room.quiz.scoreboard.scores);
      if(user.room.hasQuizFinished()) {
        user.room.quiz.status = 'idle';
        user.room.participants.forEach(participantId => {
          var participant = Users.getById(participantId);
          participant.wsConnection.sendMessage('end_quiz', {status: 'success', scores: user.room.quiz.scoreboard.scores});
        });
        Users.broadcastMessage('update_rooms', null);
      }
    } else {
      wsConnection.sendMessage('end_quiz', {status: 'failure', error: 'User not in any room'});
    }
  });

  // This is wrapper method which directs an incoming message to the proper callback
  connection.on('message', function(message) {
    if(message.type === 'utf8') {
        var msgData = JSON.parse(message.utf8Data);
        wsConnection.handleEvent(msgData.type, msgData.message);
    }
  });

  connection.on('close', function(connection) {
    // close user connection
    if(user.room !== null) {
      Rooms.removeUserFromRoom(user.userId, user.room.id);
      user.room = null;
    }
    Users.removeUser(user.userId);
    Users.broadcastMessage('update_rooms', null);
  });
});