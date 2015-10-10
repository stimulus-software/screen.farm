require 'sinatra/base'

class RestApi < Sinatra::Base
  enable :static

  get "/" do
    haml :index
  end

  post '/c/:channel' do
    post_to_channel(params[:channel], url: params[:url], file: params[:file])
  end

  get '/b/:channel' do
    post_to_channel params[:channel], url: params[:url],
      success: -> {
        haml :bookmarklet_success
      }
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

  get '/style.css' do
    sass :style
  end

  # Pair
  get '/:pco' do
    haml :index
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

    def post_to_channel(ch, params)
      channel = $registry[ch.to_s]
      if ! channel
        status 404
        "channel_not_found #{ch.inspect}\n"
      elsif ! channel.active?
        status 403
        "channel_not_active #{ch.inspect}\n"
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
        if params[:success]
          params[:success].call
        else
          "OK\n"
        end
      end
    end
  end
end
