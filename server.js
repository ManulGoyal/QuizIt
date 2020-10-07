var WebSocketServer = require('websocket').server;
var http = require('http');

var totalUsers = 0;
var clients = {};

function checkNameAvailability(name) {
    for(id in clients) {
        if(clients[id].name === name) {
            return false;
        } 
    }
    return true;
}

var server = http.createServer(function(request, response) {
  // process HTTP request. Since we're writing just WebSockets
  // server we don't have to implement anything.
});
server.listen(1337, function() { });

// create the server
wsServer = new WebSocketServer({
  httpServer: server
});

// WebSocket server
wsServer.on('request', function(request) {
  var connection = request.accept(null, request.origin);
  var username, userid;
  userid = totalUsers;
  totalUsers++;
  connection.sendUTF(JSON.stringify({type: 'status', message: 'success'}));

  // This is the most important callback for us, we'll handle
  // all messages from users here.
  connection.on('message', function(message) {
    if(message.type === 'utf8') {
        var msgData = JSON.parse(message.utf8Data);
        if(msgData.type == 'username') {
            console.log(msgData);
            if(checkNameAvailability(msgData.message)) {
                clients[userid] = {name: msgData.message, connection: connection};
                connection.sendUTF(JSON.stringify({type: 'username', message: 'success'}));
            } else {
                connection.sendUTF(JSON.stringify({type: 'username', message: 'failure'}));
            }
            
        }
    }
  });

  connection.on('close', function(connection) {
    // close user connection
    delete clients[userid];
  });
});