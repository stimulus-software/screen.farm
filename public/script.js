var socket = new WebSocket("ws://" + window.location.host + "/");
socket.onopen = function (event) {
  console.log("Sending");
}

var displayWindow = null;

socket.onmessage = function (event) {
  console.log(event.data);
  message = JSON.parse(event.data);
  console.log("message:", message);
  if (message.command == 'init') {
    $('#info').text("Channel " + message.channel);
  }
  else if (message.command == 'show') {
    displayWindow = window.open(message.url, 'display');
  }
}
