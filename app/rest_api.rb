require 'sinatra/base'

class RestApi < Sinatra::Base
  post '/c/:channel' do
    if params[:channel] == 'all'
      $channel_registry.all_active.each do |channel|
        channel.show(url: params[:url])
      end
      "OK\n"
    else
      channel = $channel_registry[params[:channel].to_s]
      if ! channel
        status 404
        "channel_not_found #{params[:channel].inspect}\n"
      elsif ! channel.active?
        status 403
        "channel_not_active #{params[:channel].inspect}\n"
      else
        channel.show(url: params[:url])
        "OK\n"
      end
    end
  end

  post '/f' do
    puts params.inspect
    f = params['file']

    id = rand(10**32).to_s

    $files[id] = {
      name: f[:filename],
      type: f[:type],
      content: f[:tempfile].read
    }

    "#{id}#{File.extname(f[:filename])}\n"
  end

  get '/f/:id' do
    id = File.basename(params[:id], ".*")
    f = $files[id]
    if f
      content_type f[:type]
      f[:content]
    else
      status 404
      "not_found"
    end
  end

  get '/health' do
    "OK\n"
  end
end
