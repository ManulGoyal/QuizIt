## Introduction

Quizzing is an interesting game, where several competitors play against each other by trying to give correct answers to diﬀerent questions based on different topics. It can be played both as a sport, and as an academic activity, and on a whole helps in enriching the knowledge of the player.
In this project we try to create an android based application for quizzing - the QuizIt. QuizIt is an application that mainly targets competitive quizing, although it can as well be used for academic purposes. We try to model real world quizzes in this application, mainly by introducing room formation and quiz creation. To do this we have created a system facilitating full-duplex communication between the client and server, by using the WebSockets which is a full duplex communication protocol built over the http protocol.

## Usage

Note: An apk file is directly provided in QuizIt folder for direct installation and running.

1. Clone the repository.
`git clone https://github.com/ManulGoyal/QuizIt.git`

2. Switch to repository directory.
`cd QuizIt`

3. Open 'quiz_it' folder as a flutter project in Android Studio and run the app.

4. Enter any username you wish, and click 'Connect'.

## Instructions

### Server-side
In order to ensure consistency, whenever a message is passed from the server to client or vice-versa, please use the following syntax (here `wsConnection` is a `WebSocketConnection` object):

```
wsConnection.sendMessage('<type of message (string)>', <JavaScript object representing the message (this will be automatically passed in the 'message' field of the JSON object to be sent)>);
```
To attach a listener for incoming messages from client connection `wsConnection`:
```
wsConnection.addListener('<type of message (string)>', function (message) {
    // do something with the received JavaScript object 'message'
    // which contains the JSON-decoded value of the 'message' field of the received JSON object
});
```

### Client-side
To attach an event handler on the client side use (here `connection` is a `WebSocketConnection` object, and `dynamic` object means a object of any data type, ex. `String`, `Map<String, dynamic>`, `int`, etc.):
```
connection.addListener('<type of message>', (msg) {
    // do something with the dynamic object msg, which contains the JSON-decoded value
    // of the 'message' field in the JSON object recieved from server 
});
```
To send a message to the server, use
```
connection.sendMessage('<type of message (String)>', <dynamic object representing the message (which will be passed automatically in the 'message' field of the JSON object sent to server)>);
```

## API
Whenever some API is exposed (i.e., an event handler is written in backend to handle a message from the client), please document it in this section.
Every time a change occurs in the Rooms class on the server side, it needs to be broadcasted to all the connected users. To accomplish this, a message of type 'update_rooms' must be sent to all the users as follows:
```
Users.broadcastMessage('update_rooms', null);
```
This message just informs the clients that a change has taken place, and should be handled on the client side in different ways on different screens. For example, a client may request a particular room or a list of all rooms when he is alerted of this change, as desired. This message is sent when a User closes the connection, so that if he was in a room, he would be removed from it and this should be informed to the clients.

| Message from Client   | Response from Server | Purpose |
| --------------------- | ----------------- | -------------------- |
| `{type: 'username', message: '<username>'}` | `{type: 'username', message: {status: 'success/failure', [userId: userId]/[error: '<error>']}}` | Register the name of the user with the server while connecting. Returns failure if username is already taken alongwith an error, otherwise returns the user ID of the newly created user. | 
| `{type: 'get_rooms_all', message: null}` | `{type: 'get_rooms_all', message: <list of all public rooms>}` | Returns the list of all Room objects with status == 'public'. |
| `{type: 'get_room_by_id', message: <room_id>}` | `{type: 'get_room_by_id', message: {status: 'success/failure', [room: <Room object>, participants: <list of room particpants>]/[error: '<error>']}}` | Returns the room and the list of participants with supplies ID, and error if such a room doesn't exist. The room returned is a Room object, and each participant in the list is an object `{userId: <user id>, username: '<username>'`.|
| `{type: 'add_room', message: {name: '<room name>', access: 'public/private', maxSize: <max size>}}` | `{type: 'add_room', message: {status: 'success/failure', [room_id: <room id>]/[error: '<error>']}}` | Creates a new room with supplied data, and adds the requesting user as the host and as a participant. Returns failure if room name is taken or if requesting user is already in another room. Broadcasts 'update_rooms'.|
| `{type: 'add_to_room', message: <room id>}` | `{type: 'add_to_room', message: {status: 'success/failure', [error: '<error>']}}` | Adds the requesting user to the room with supplied room ID. Returns failure if room doesn't exist, room is already full, user is already present in this room or another room. Broadcasts 'update_rooms'.|
| `{type: 'remove_from_room', message: null}` | `{type: 'remove_from_room', message: {status: 'success/failure', [origin: 'self']/[error: '<error>']}}` | Remove the requesting user from his current room. Property 'origin' describes what caused the user to be removed. Returns failure if user is not in any room. If the requesting user is the host of his room, the room is disbanded and all participants are removed from this room, but 'remove_from_room' is NOT sent to the participants except the host. Broadcasts 'update_rooms'.|
| `{type: 'remove_user_from_room', message: <user id>}` | `{type: 'remove_user_from_room', message: {status: 'success/failure', [error: '<error>']}}` and `{type: 'remove_from_room', message: {status: 'success/failure', [origin: 'host']/[error: '<error>']}}` | Removes the user with supplied user ID from the room the requesting user is currently in. Returns failure if requesting user is not in any room, or he is not the host of this room, or supplied user ID is the room's host's ID (if host wants to leave the room himself, he should use 'remove_from_room'). Also, in case of success, an additional 'remove_from_room' response is sent to the user who is about to be removed, with 'origin' property set to 'host'. Broadcasts 'update_rooms'.|
| `{type: 'get_room_by_code', message: <room code>}` | `{type: 'get_room_by_code', message: {status: 'success/failure', [room: <Room object>]/[error: '<error>']}}` | Returns the Room object with the supplied invite code; returns failure if no such room exists. |


