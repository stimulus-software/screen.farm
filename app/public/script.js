// Generated by LiveScript 1.4.0
(function(){
  var localGet, localSet, localGetOrIssue, sid, sco, fid, pco, displayWindow, socket, opening, reconnectAttempts, sendMessage, parseMessage, connect, reconnectTimeout, reconnect;
  localGet = function(name){
    return localStorage.getItem(name);
  };
  localSet = function(name, value){
    return localStorage.setItem(name, value);
  };
  localGetOrIssue = function(name){
    var value;
    if ((value = localGet(name)) == null) {
      localSet(name, value = (Math.random() * Math.pow(256, 16)).toString(36));
    }
    return value;
  };
  sid = localGetOrIssue('sid');
  sco = localGet('sco');
  fid = localGetOrIssue('fid');
  pco = location.pathname.replace(/^\//, '');
  if (pco === '') {
    pco = null;
  }
  console.log("sid", sid);
  console.log("fid", fid);
  console.log("sco", sco);
  console.log("pco", pco);
  displayWindow = null;
  socket = null;
  opening = false;
  reconnectAttempts = 0;
  sendMessage = function(command, params){
    console.warn("->", JSON.stringify([command, params]));
    return socket.send(JSON.stringify([command, params]));
  };
  parseMessage = function(message){
    return JSON.parse(message);
  };
  connect = function(){
    if (!socket || socket.readyState !== WebSocket.OPEN && !opening) {
      opening = true;
      socket = new WebSocket("ws://" + location.host + "/");
      socket.onopen = function(event){
        reconnectAttempts = 0;
        opening = false;
        return sendMessage("connect", {
          sid: sid,
          fid: fid,
          sco: sco,
          pco: pco
        });
      };
      socket.onmessage = function(event){
        var ref$, command, params, fid, sco, pco, url, qrcode, msg;
        console.log("RECEIVED", event.data);
        ref$ = parseMessage(event.data), command = ref$[0], params = ref$[1];
        switch (command) {
        case 'connected':
          fid = params.fid, sco = params.sco;
          localSet('fid', fid);
          localSet('sco', sco);
          return $('#info').text("f:" + fid + ":" + sco + " / s:" + sid);
        case 'paircode':
          pco = params.pco;
          url = location.origin + "/" + pco;
          $('#test').text('');
          qrcode = new QRCode("test", {
            width: 256,
            height: 256,
            colorDark: '#000000',
            colorLight: '#ffffff',
            correctLevel: QRCode.CorrectLevel.H
          });
          qrcode.makeCode(url);
          return $('#url').text(url);
        case 'show':
          url = params.url;
          if (displayWindow) {
            displayWindow.close();
          }
          return setTimeout(function(){
            return displayWindow = window.open(url, 'screen_farm_display');
          }, 100);
        case 'error':
          msg = params.msg;
          return console.error("Backend says:", msg);
        default:
          throw "Unknown command: " + command;
        }
      };
      socket.onclose = function(event){
        opening = false;
        return reconnect();
      };
      return socket.onerror = function(event){
        return console.error("WebSocket Error", event);
      };
    }
  };
  reconnectTimeout = null;
  reconnect = function(){
    var waitTimeMed, waitTime;
    if (!reconnectTimeout) {
      reconnectAttempts = reconnectAttempts + 1;
      waitTimeMed = (Math.pow(2, reconnectAttempts) / 10) * 1000;
      waitTime = (Math.random() + 0.5) * waitTimeMed;
      console.log("delay: ", waitTime, waitTimeMed);
      return reconnectTimeout = setTimeout(function(){
        reconnectTimeout = null;
        return connect();
      }, waitTime);
    }
  };
  connect();
}).call(this);

//# sourceMappingURL=script.js.map
