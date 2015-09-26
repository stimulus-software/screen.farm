require 'faye/websocket'
require 'json'
require 'pathname'

APP_PATH = Pathname.new(File.dirname(__FILE__))
$: << APP_PATH.join('app').to_s

require 'channel_registry'
require 'channel_server'


$channel_registry = ChannelRegistry.new


App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    ChannelServer.new(Faye::WebSocket.new(env), $channel_registry.issue).run

  else
    # Normal HTTP request
    [200, {'Content-Type' => 'text/plain'}, ['Hello']]
  end
end

