var socket = new WebSocket("ws://localhost:9292/");
socket.onopen = function (event) {
  console.log("Sending");
}

socket.onmessage = function (event) {
  console.log(event.data);
  message = JSON.parse(event.data);
  console.log("message:", message);
  if (message.command == 'init') {
    $('#info').text("Channel " + message.channel);
  }
  else if (message.command == 'show') {
    window.open(message.url, 'display');
  }
}
