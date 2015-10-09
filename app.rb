require 'faye/websocket'
require 'json'
require 'pathname'
require 'hashie'
require 'redis'

APP_PATH = Pathname.new(File.dirname(__FILE__))
$: << APP_PATH.join('app').to_s

def import(s)
  # development
  load "#{s}.rb"

  # production
  require s
end

import 'registry'

$registry = Registry.new
$files = {}
$redis = Redis.new host: 'localhost', port: 4015


App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    import 'websocket_handler'
    WebsocketHandler.new(Faye::WebSocket.new(env), $registry).run
  else
    # Normal HTTP request
    load 'rest_api.rb'
    RestApi.new.call(env)
  end
end

