require 'sinatra/base'

class RestApi < Sinatra::Base
  enable :static

  get "/" do
    send_file File.join(settings.public_folder, 'index.html')
  end

  post '/c/:channel' do
    channel = $channel_registry[params[:channel].to_s]
    if ! channel
      status 404
      "channel_not_found #{params[:channel].inspect}\n"
    elsif ! channel.active?
      status 403
      "channel_not_active #{params[:channel].inspect}\n"
    else
      url =
        if params[:file]
          filename = store_file(params[:file], 5*60)
          if params[:file][:type].start_with?('image/')
            "/i/#{filename}"
          else
            "/f/#{filename}"
          end
        else
          params[:url]
        end
      channel.show(url: url)
      "OK\n"
    end
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

  get '/i/:id' do
    haml :image_page, locals: { file_id: params[:id] }
  end

  get '/health' do
    "OK\n"
  end

  helpers do
    def store_file(f, ttl)
      id = rand(10**32).to_s

      $files[id] = {
        name: f[:filename],
        type: f[:type],
        content: f[:tempfile].read
      }

      "#{id}#{File.extname(f[:filename])}\n"
    end
  end
end
