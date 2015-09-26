var socket = new WebSocket("ws://" + window.location.host + "/");
socket.onopen = function (event) {
  channel = localStorage.getItem('channel');
  socket.send(JSON.stringify({
    command: 'init',
    channel: channel
  }));
}

var displayWindow = null;

socket.onmessage = function (event) {
  console.log(event.data);
  message = JSON.parse(event.data);
  console.log("message:", message);
  if (message.command == 'init') {
    channel = message.channel;
    localStorage.setItem('channel', channel);
    $('#info').text(message.channel);
  }
  else if (message.command == 'show') {
    //displayWindow = window.open('', 'display');
    if (displayWindow) {
      displayWindow.close();
    }
    setTimeout(function () {
      displayWindow = window.open(message.url, 'display');
    }, 100);
  }
}
