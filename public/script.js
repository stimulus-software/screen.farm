
var socket = new WebSocket("ws://localhost:9292/");
socket.onopen = function (event) {
  console.log("Sending");
  socket.send("Here's some text that the server is urgently awaiting!");
}
