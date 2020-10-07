## Usage

1. Clone the repository.
`git clone https://github.com/ManulGoyal/QuizIt.git`

2. Switch to repository directory.
`cd QuizIt`

3. Install websocket npm module.
`npm install websocket`

4. Run the server.
`node server.js`

5. Open 'quiz_it' folder as a flutter project in Android Studio and run the app.

6. If running on Android Virtual Device, type in the IP 'ws://10.0.2.2:1337' and any username you wish, and click 'Connect'.

## Instructions

In order to ensure consistency, whenever a message is passed from the server to client or vice-versa, please pass it as a UTF-8 string-encoded JSON object with the following fields:

```
{
    type: "<the type of message>"
    message: "<the actual message, can be another string-encoded JSON>"
}
```

Also, whenever some API is exposed (i.e., an event handler is written in backend to handle a message from the client), please document it in the next section.
To attach an event handler on the client side use (here `connection` is a `WebSocketConnection` object):
```
connection.addListener('<type of message>', (msg) {
    // do something with the String msg, which contains the value
    // of the 'message' field in the JSON object recieved from server 
});
```

## API

| Message from Client   | Response from Server | Purpose |
| --------------------- | ----------------- | -------------------- |
| `{type: 'username', message: '<username>'}` | `{type: 'username', message: 'success\|failure'}` | Register the name of the user with the server while connecting. Returns failure if username is already taken. | 

