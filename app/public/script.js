// Generated by LiveScript 1.4.0
(function(){
  var localGet, localSet, localGetOrIssue, sid, sco, fid, pco, displayWindow, socket, opening, reconnectAttempts, sendMessage, parseMessage, connect, reconnectTimeout, reconnect, resetMenu, updateSco, resizeSco, updateScoDisplay;
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
    var message;
    message = JSON.stringify([command, params]);
    console.log("SENDING", message);
    return socket.send(message);
  };
  parseMessage = function(message){
    return JSON.parse(message);
  };
  connect = function(){
    var proto;
    if (!socket || socket.readyState !== WebSocket.OPEN && !opening) {
      opening = true;
      proto = location.origin.indexOf('https://') === 0 && 'wss' || 'ws';
      socket = new WebSocket(proto + "://" + location.host + "/");
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
        var ref$, command, params, pco, url, width, qrcode, state, elemIds, i$, len$, item, makeBookmarklet, elemId, $elem, $blet, msg;
        console.log("fid", fid);
        console.log("RECEIVED", event.data);
        ref$ = parseMessage(event.data), command = ref$[0], params = ref$[1];
        switch (command) {
        case 'connected':
          fid = params.fid, sco = params.sco;
          localSet('fid', fid);
          localSet('sco', sco);
          $('#loading').hide();
          $('.root-url').text(location.origin);
          $('.fid').text(fid);
          $('.sid').text(sid);
          $('.sco').text(sco);
          $('input#sco-input').val(sco);
          resizeSco();
          if (location.pathname !== "/") {
            return history.replaceState({}, "", location.origin);
          }
          break;
        case 'paircode':
          pco = params.pco;
          url = location.origin + "/" + pco;
          $('#qrcode').text('');
          $('#url').text(url);
          width = $('#qrcode-pane').width();
          qrcode = new QRCode("qrcode", {
            width: width,
            height: width,
            colorDark: '#000000',
            colorLight: '#ffffff',
            correctLevel: QRCode.CorrectLevel.H
          });
          return qrcode.makeCode(url);
        case 'show':
          url = params.url;
          if (displayWindow) {
            displayWindow.close();
          }
          return setTimeout(function(){
            return displayWindow = window.open(url, 'screen_farm_display');
          }, 100);
        case 'state':
          state = params.state;
          elemIds = [];
          for (i$ = 0, len$ = state.length; i$ < len$; ++i$) {
            item = state[i$];
            makeBookmarklet = fn$;
            elemId = "s-" + item.sid;
            elemIds.push(elemId);
            if (($elem = $('#screens').find('#' + elemId)).length) {
              $blet = $elem.find('a.bookmarklet');
              if ($blet.text() !== item.sco) {
                $blet.text(item.sco);
                $blet.attr('href', makeBookmarklet(item.sco));
              }
            } else {
              $('#screens').append($('<div>').addClass('screen').attr('id', elemId).append($('<a>').addClass('bookmarklet').text(item.sco).attr('href', makeBookmarklet(item.sco))));
            }
          }
          return $('#screens .screen').map(function(){
            if (elemIds.indexOf(this.id) === -1) {
              return $(this).remove();
            }
          });
        case 'error':
          msg = params.msg;
          return console.error("Backend says:", msg);
        default:
          throw "Unknown command: " + command;
        }
        function fn$(sco){
          return "javascript:(function(){var v = window.open('" + location.origin + "/b/f:" + fid + ":" + sco + "?url='+encodeURIComponent(location.href))})();";
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
      return reconnectTimeout = setTimeout(function(){
        reconnectTimeout = null;
        return connect();
      }, waitTime);
    }
  };
  connect();
  resetMenu = function(){
    $('.pane').hide();
    $('#info-btn').text("Show info");
    return $('#add-btn').text("Add screen");
  };
  $(function(){
    $('#info-btn').click(function(){
      if ($('#info-pane').is(':visible')) {
        return resetMenu();
      } else {
        resetMenu();
        $('#info-pane').show();
        return $('#info-btn').text("Hide info");
      }
    });
    $('#add-btn').click(function(){
      if ($('#qrcode-pane').is(':visible')) {
        return resetMenu();
      } else {
        resetMenu();
        $('#qrcode-pane').show();
        return $('#add-btn').text("Hide");
      }
    });
    $('#sco-input').change(function(){
      return updateSco();
    });
    $('#sco-input').keypress(function(ev){
      updateSco();
      if (ev.charCode === 13 || ev.keycode === 13) {
        $('#sco-input').blur();
        return updateScoDisplay();
      }
    });
    $('#sco-input').blur(function(ev){
      updateSco();
      return updateScoDisplay();
    });
    return $('#sco-input').keyup(function(){
      return updateSco();
    });
  });
  updateSco = function(){
    sco = $('#sco-input').val();
    localSet('sco', sco);
    sendMessage('sco', {
      fid: fid,
      sco: sco
    });
    return resizeSco();
  };
  resizeSco = function(){
    var charWidth;
    charWidth = Math.min(72, Math.max(24, 300 / sco.length));
    return $('#sco-input').css('font-size', charWidth);
  };
  updateScoDisplay = function(){
    return $('.sco').text(sco);
  };
}).call(this);

//# sourceMappingURL=script.js.map
