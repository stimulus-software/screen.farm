class Channel
  attr_reader :id, :ws

  def initialize(id, ws)
    @id = id
    @ws = ws or raise "ws missing"
  end

  def run
    ws.on :open do |event|
      with_rescue do
        send_message command: 'init', channel: id
      end
    end

    ws.on :message do |event|
      with_rescue do
        ws.send("Echo #{event.data}")
      end
    end

    ws.on :close do |event|
      with_rescue do
        p [:close, event.code, event.reason]
        @ws = nil
      end
    end

    # Return async Rack response
    ws.rack_response
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


  def show(params)
    send_message({ command: 'show' }.merge params)
  end
end


