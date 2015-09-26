class WebsocketHandler
  attr_reader :ws, :channel_registry

  def initialize(ws, channel_registry)
    @ws = ws
    @channel_registry = channel_registry
  end

  def run
    @ws.on :message do |event|
      with_rescue do
        m = JSON.parse(event.data)
        handle_command(m)
      end
    end

    @ws.on :close do |event|
      with_rescue do
        p [:close, event.code, event.reason]
        @ws = nil
        @channel.unsubscribe(self) if @channel
      end
    end

    ws.rack_response
  end

  def handle_command(m)
    case m['command']
    when 'init'
      channel_id = m['channel']
      if channel_id && channel_id.length > 1
        @channel = @channel_registry[channel_id]
      else
        @channel = @channel_registry.issue
      end
      @channel.subscribe(self)
      send_message command: 'init', channel: @channel.id
    else
      puts "Unknown command: #{m['command'].inspect}"
    end
  end

  def send_message(hash)
    s = JSON.generate(hash)
    ws.send(s)
  end


  def with_rescue
    yield
  rescue => e
    puts "ERROR: #{e.class}: #{e.message}"
    puts e.backtrace
  end
end
