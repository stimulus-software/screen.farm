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
import 'channel_server'

$channel_registry = ChannelRegistry.new

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    channel = $channel_registry.issue(Faye::WebSocket.new(env))
    channel.run
  else
    # Normal HTTP request
    load 'rest_api.rb'
    RestApi.new.call(env)
  end
end

