require 'faye/websocket'
require 'json'
require 'pathname'

APP_PATH = Pathname.new(File.dirname(__FILE__))
$: << APP_PATH.join('app').to_s

def import(s)
  # development
  load "#{s}.rb"

  # production
  require s
end

import 'channel_registry'
import 'websocket_handler'

$channel_registry = ChannelRegistry.new
$files = {}


App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    WebsocketHandler.new(Faye::WebSocket.new(env), $channel_registry).run
  else
    # Normal HTTP request
    load 'rest_api.rb'
    RestApi.new.call(env)
  end
end

