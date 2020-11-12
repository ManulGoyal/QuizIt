import {Quiz, QuizQuestion} from './quiz_utils.js';

export const User = class {
    constructor(username, wsConnection) {
        this.userId = -1;
        this.username = username;
        this.wsConnection = wsConnection;
        this.room = null;
    }
}

export const Room = class {
    constructor(name, code, access, maxSize, host, participants) {
        this.id = -1;
        this.name = name;
        this.code = code;
        this.access = access;
        this.maxSize = maxSize;
        this.host = host;
        this.participants = participants;
        this.quiz = new Quiz('NA');   // the quiz associated with this room, a Quiz class object
    }
    isUserPresent(userId) {
        console.log(this.participants);
        console.log(userId);
        console.log(userId in this.participants);
        return this.participants.includes(userId);
    }
    isFull() {
        return this.participants.length >= this.maxSize;
    }
    addParticipant(userId) {
        console.log(Users.users);
        if(!(userId in Users.users)) {
            console.log(User.users);
            console.log("here3");
            return false;
        }
        if(this.isFull()) {
            console.log('here4');
            return false;
        }
        if(this.isUserPresent(userId)) {
            console.log(userId);
            console.log('here5');
            return false;
        }
        this.participants.push(userId);
        return true;
    }
    getParticipants() {
        var participants = [];
        this.participants.forEach(function (userId) {
            var user = Users.getById(userId);
            // console.log(userId);
            // console.log(user);
            if(user) {
                participants.push({userId: user.userId, username: user.username});
            }
        });
        return participants;
    }

    // returns the JSON representation of the Room object, without the quiz questions
    // associated with the Room, useful for room management screen on client-side
    getQuizlessJSON() {
        var {quiz, ...roomQuizless} = this;
        return {
            ...roomQuizless,
            quiz_topic: this.quiz.topic,
            quiz_length: this.quiz.getNumberOfQuestions
        };
    }
}

export const Users = class {
    static users = {};
    static totalUsers = 0;

    static getAll() {
        var usersList = [];
        for(var id in this.users) {
            usersList.push(this.users[id]);
        }
        return usersList;
    }

    static getById(userId) {
        if(userId in this.users) {
            return this.users[userId];
        }
        return null;
    } 

    static checkNameAvailability(name) {
        for(var id in this.users) {
            if(this.users[id].username === name) {
                return false;
            }
        }
        return true;
    }
    static addUser(user) {
        if(user === undefined) return false;
        if(this.checkNameAvailability(user.username)) {
            user.userId = this.totalUsers;
            this.users[this.totalUsers] = user;
            this.totalUsers++;
            return true;
        }
        return false;
    }
    static removeUser(userId) {
        // if(user === undefined) return false;
        if(userId in this.users) {
            delete this.users[userId];
            return true;
        }
        return false;
    }
    static broadcastMessage(type, message) {
        for(var id in this.users) {
            this.users[id].wsConnection.sendMessage(type, message);
        }
    }
}

export const Rooms = class {
    static rooms = {};
    static totalRooms = 0;

    static getAll(privateRooms) {
        var roomsList = [];
        for(var id in this.rooms) {
            if(!privateRooms && this.rooms[id].access === 'private') {
                continue;
            }
            roomsList.push(this.rooms[id]);
        }
        return roomsList;
    }

    static getById(id) {
        if(id in this.rooms) {
            return this.rooms[id];
        }
        return null;
    }

    static getByCode(code) {
        for(var id in this.rooms) {
            if(this.rooms[id].code == code) {
                return this.rooms[id];
            }
        }
        return null;
    }

    static checkNameAvailability(name) {
        for(var id in this.rooms) {
            if(this.rooms[id].name === name) {
                return false;
            }
        }
        return true;
    }
    static addRoom(room) {
        if(room === undefined) return false;
        if(this.checkNameAvailability(room.name)) {
            room.id = this.totalRooms;
            this.rooms[this.totalRooms] = room;
            this.totalRooms++;
            return true;
        }
        return false;
    }
    static removeRoom(roomId) {
        // if(room === undefined) return false;
        if(roomId in this.rooms) {
            delete this.rooms[roomId];
            return true;
        }
        return false;
    }
    static isRoomFull(roomId) {
        var room = this.getById(roomId);
        if(room) {
            return room.isFull();
        }
        return false;
    }
    static isUserInRoom(userId, roomId) {
        if(!(roomId in this.rooms) || !(userId in Users.users)) return false;
        return this.rooms[roomId].isUserPresent(userId);
    }
    static addUserToRoom(userId, roomId) {
        var room = this.getById(roomId);
        console.log(room);
        if(room) {
            return room.addParticipant(userId);
        }
        return false;
    }
    static removeUserFromRoom(userId, roomId) {
        var room = this.getById(roomId);
        if(room) {
            var index = room.participants.indexOf(userId);
            if(index > -1) {
                room.participants.splice(index, 1);
                if(room.host === userId || room.participants.length === 0) {
                    room.participants.forEach(function (userId) {
                        var user = Users.getById(userId);
                        if(user) {
                            user.room = null;
                        }
                    });
                    this.removeRoom(room.id);
                }
                return true;
            }
        }
        return false;
    }
}
 
export const WebSocketConnection = class {

    constructor(connection) {
        this.connection = connection;
        this.eventListeners = {};
    }

    addListener(event, callback) {
        this.eventListeners[event] = callback;
    }

    handleEvent(event, message) {
        if(event in this.eventListeners) {
            this.eventListeners[event](message);
            return true;
        }
        return false;
    }

    sendMessage(type, message) {
        this.connection.sendUTF(JSON.stringify({type: type, message: message}));
    }
}

export const randomString = function(length) {
    var result           = '';
    var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var charactersLength = characters.length;
    for ( var i = 0; i < length; i++ ) {
       result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
 }