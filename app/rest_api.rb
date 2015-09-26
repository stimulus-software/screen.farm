require 'sinatra/base'

class RestApi < Sinatra::Base
  post '/c/:channel' do
    channel = $channel_registry[params[:channel].to_s]
    if channel
      channel.show(url: params[:url])
    else
      status 404
      "channel_not_found #{params[:channel].inspect}\n"
    end
  end

  get '/health' do
    "OK\n"
  end
end
