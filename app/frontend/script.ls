local-get = (name) -> local-storage.get-item name
local-set = (name, value) -> local-storage.set-item name, value

local-get-or-issue = (name) ->
  unless (value = local-get name)?
    local-set name, (value = (Math.random! * 256^16).to-string(36))
  value

sid = local-get-or-issue 'sid' # Screen ID
sco = local-get 'sco' # Screen Code
fid = local-get-or-issue 'fid' # Farm ID
pco = location.pathname.replace /^\//, ''
pco = null if pco == ''

console.log "sid", sid
console.log "fid", fid
console.log "sco", sco
console.log "pco", pco

display-window = null

socket = null
opening = false
reconnect-attempts = 0

send-message = (command, params) ->
  console.warn "->", JSON.stringify([command, params])
  socket.send JSON.stringify([command, params])

parse-message = (message) -> JSON.parse(message)

connect = ->
  if ! socket || socket.ready-state != WebSocket.OPEN && ! opening
    opening := true
    socket := new WebSocket "ws://#{location.host}/"

    socket.onopen = (event) ->
      reconnect-attempts := 0
      opening := false
      send-message "connect", {sid, fid, sco, pco}

    socket.onmessage = (event) ->
      console.log "RECEIVED", event.data
      [command, params] = parse-message event.data
      switch command
      case 'connected'
        {fid, sco} = params
        local-set 'fid', fid
        local-set 'sco', sco
        $('#info').text("f:#{fid}:#{sco} / s:#{sid}")
      case 'paircode'
        {pco} = params
        url = "#{location.origin}/#{pco}"
        $('#test').text('')
        qrcode = new QRCode("test", {
          width: 256
          height: 256
          colorDark : '#000000'
          colorLight : '#ffffff'
          correctLevel : QRCode.CorrectLevel.H
        })
        qrcode.makeCode(url)
        $('#url').text(url)

      case 'show'
        {url} = params
        display-window.close! if display-window
        set-timeout do
          -> display-window := window.open url, 'screen_farm_display'
          100

      case 'error'
        {msg} = params
        console.error "Backend says:", msg
      else
        throw "Unknown command: #{command}"

    socket.onclose = (event) ->
      opening := false
      reconnect!

    socket.onerror = (event) ->
      console.error "WebSocket Error", event

reconnect-timeout = null

reconnect = ->
  unless reconnect-timeout
    reconnect-attempts := reconnect-attempts + 1
    wait-time-med = (Math.pow(2, reconnect-attempts) /10) * 1000
    wait-time = (Math.random! + 0.5) * wait-time-med
    console.log "delay: ", wait-time, wait-time-med
    reconnect-timeout :=
      setTimeout do
        ->
          reconnect-timeout := null
          connect!
        wait-time

connect!
