local-get = (name) -> local-storage.get-item name
local-set = (name, value) -> local-storage.set-item name, value

local-get-or-issue = (name) ->
  unless (value = local-get name)?
    local-set name, (value = (Math.random! * 256^64).to-string(36))
  value

sid = local-get-or-issue 'sid' # Screen ID
sco = local-get 'sco' # Screen Code
fid = local-get-or-issue 'fid' # Farm ID

console.log "sid", sid
console.log "fid", fid
console.log "sco", sco

socket = new WebSocket "ws://#{location.host}/"

send-message = (command, params) -> 
  console.warn "->", JSON.stringify([command, params])
  socket.send JSON.stringify([command, params])
parse-message = (message) -> JSON.parse(message)

socket.onopen = (event) ->
  send-message "connect", {sid, fid, sco}

socket.onmessage = (event) ->
  console.log "RECEIVED", event.data
  [command, params] = parse-message event.data
  switch command
  case 'connected'
    {fid, sco} = params
    local-set 'fid', fid
    local-set 'sco', sco
  case 'error'
    {msg} = params
    console.error "Backend says:", msg
  else
    throw "Unknown command: #{command}"


# var socket = new WebSocket("ws://" + window.location.host + "/");
# socket.onopen = function (event) {
#   channel = localStorage.getItem('channel');
#   socket.send(JSON.stringify({
#     command: 'init',
#     channel: channel
#   }));
# }
#
# var displayWindow = null;
#
# socket.onmessage = function (event) {
#   console.log(event.data);
#   message = JSON.parse(event.data);
#   console.log("message:", message);
#   if (message.command == 'init') {
#     channel = message.channel;
#     localStorage.setItem('channel', channel);
#     $('#info').text(message.channel);
#   }
#   else if (message.command == 'show') {
#     //displayWindow = window.open('', 'display');
#     if (displayWindow) {
#       displayWindow.close();
#     }
#     setTimeout(function () {
#       displayWindow = window.open(message.url, 'display');
#     }, 100);
#   }
# }
