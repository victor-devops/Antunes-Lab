let events = require('events');

let listenerCallback = (data) => {
    console.log('celebrate ' + data);
}

let myEmitter = new events.EventEmitter();

myEmitter.on('celebration', listenerCallback)

myEmitter.emit('celebration', 'New Year')