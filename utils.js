export const User = class {
    constructor(username, wsConnection) {
        this.userId = -1;
        this.username = username;
        this.wsConnection = wsConnection;
    }
}

export const Room = class {
    constructor(name, code, access, maxSize, participants) {
        this.id = -1;
        this.name = name;
        this.code = code;
        this.access = access;
        this.maxSize = maxSize;
        this.participants = participants;
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
    static removeUser(user) {
        if(user === undefined) return false;
        if(user.userId in this.users) {
            delete this.users[user.userId];
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
    static removeRoom(room) {
        if(room === undefined) return false;
        if(room.id in this.rooms) {
            delete this.rooms[room.id];
            return true;
        }
        return false;
    }
    static removeUserFromRoom(user) {
        for(var id in this.rooms) {
            var room = this.rooms[id];
            var index = room.participants.indexOf(user.userId);
            if(index > -1) {
                room.participants.splice(index, 1);
            }
            if(room.participants.length === 0) {
                this.removeRoom(room);
            }
        }
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