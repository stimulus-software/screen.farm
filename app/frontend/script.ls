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
  message = JSON.stringify([command, params])
  console.log "SENDING", message
  socket.send message

parse-message = (message) -> JSON.parse(message)

connect = ->
  if ! socket || socket.ready-state != WebSocket.OPEN && ! opening
    opening := true
    proto = (location.origin.index-of('https://') == 0) && 'wss' || 'ws'
    socket := new WebSocket "#{proto}://#{location.host}/"

    socket.onopen = (event) ->
      reconnect-attempts := 0
      opening := false
      send-message "connect", {sid, fid, sco, pco}

    socket.onmessage = (event) ->
      console.log "fid", fid
      console.log "RECEIVED", event.data
      [command, params] = parse-message event.data
      switch command
      case 'connected'
        {fid, sco} := params
        local-set 'fid', fid
        local-set 'sco', sco
        $('#loading').hide()
        $('.root-url').text(location.origin)
        $('.fid').text(fid)
        $('.sid').text(sid)
        $('.sco').text(sco)
        $('input#sco-input').val(sco)
        resize-sco!
        if location.pathname != "/"
          history.replace-state {}, "", location.origin
      case 'paircode'
        {pco} = params
        url = "#{location.origin}/#{pco}"
        $('#qrcode').text('')
        $('#url').text(url)
        width = $('#qrcode-pane').width()
        qrcode = new QRCode("qrcode", {
          width: width
          height: width
          colorDark : '#000000'
          colorLight : '#ffffff'
          correctLevel : QRCode.CorrectLevel.H
        })
        qrcode.makeCode(url)

      case 'show'
        {url} = params
        display-window.close! if display-window
        set-timeout do
          -> display-window := window.open url, 'screen_farm_display'
          100

      case 'state'
        {state} = params

        elem-ids = []
        for item in state
          make-bookmarklet = (sco) ->
            "javascript:(function(){var v = window.open('#{location.origin}/b/f:#{fid}:#{sco}?url='+encodeURIComponent(location.href))})();"

          elem-id = "s-#{item.sid}"
          elem-ids.push(elem-id)
          if ($elem = $('#screens').find('#'+elem-id)).length
            # Update existing ones
            $blet = $elem.find('a.bookmarklet')
            if $blet.text! != item.sco
              $blet.text(item.sco)
              $blet.attr('href', make-bookmarklet(item.sco))
          else
            # Add new ones
            $('#screens').append do
              $('<div>').add-class('screen').attr('id', elem-id).append do
                $('<a>').add-class('bookmarklet')
                  .text(item.sco)
                  .attr('href', make-bookmarklet(item.sco))

        # Remove ones that are not present in the state
        $('#screens .screen').map ->
          if elem-ids.index-of(@id) == -1
            $(@).remove!

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
    reconnect-timeout :=
      setTimeout do
        ->
          reconnect-timeout := null
          connect!
        wait-time

connect!

reset-menu = ->
  $('.pane').hide!
  $('#info-btn').text "Show info"
  $('#add-btn').text "Add screen"


$ ->
  $('#info-btn').click ->
    if $('#info-pane').is(':visible')
      reset-menu!
    else
      reset-menu!
      $('#info-pane').show!
      $('#info-btn').text "Hide info"


  $('#add-btn').click ->
    if $('#qrcode-pane').is(':visible')
      reset-menu!
    else
      reset-menu!
      $('#qrcode-pane').show!
      $('#add-btn').text "Hide"


  $('#sco-input').change -> update-sco!
  $('#sco-input').keypress (ev) ->
    update-sco!
    if ev.charCode == 13 || ev.keycode == 13
      $('#sco-input').blur!
      update-sco-display!
  $('#sco-input').blur (ev) ->
    update-sco!
    update-sco-display!
  $('#sco-input').keyup -> update-sco!

update-sco = ->
  sco := $('#sco-input').val!
  local-set 'sco', sco
  send-message 'sco', {fid, sco}
  resize-sco!

resize-sco = ->
  char-width = Math.min(72, Math.max(24, 300 / sco.length))
  $('#sco-input').css('font-size', char-width)

update-sco-display = ->
  $('.sco').text(sco)

