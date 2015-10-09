class WebsocketHandler
  attr_reader :ws, :registry

  def initialize(ws, registry)
    @ws = ws
    @registry = registry
  end

  def run
    @ws.on :message do |event|
      with_rescue do
        m = JSON.parse(event.data)
        handle_command(*m)
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

  def handle_command(command, params)
    catch :halt do
      params = Hashie::Mash.new params
      case command
      when 'connect'
        # [sid,pco] => lookup pco=>fid, issue sco, return [fid,sco]
        # [sid,fid] => return [fid,sco]

        sid = params.sid or halt_with_error "sid missing in connect"
        sco = params.sco
        pco = params.pco
        fid = params.fid
        (pco || fid) or halt_with_error "pco and fid missing in connect"

        if pco
          fid = registry.lookup_pco(pco)
          sco = registry.issue_sco(fid)
        else
          sco ||= registry.issue_sco(fid)
        end
        registry.subscribe(fid, sco, sid, self)
        send_message 'connected', fid: fid, sco: sco

      #when 'init'
        #channel_id = m['channel']
        #if channel_id && channel_id.length > 1
          #@channel = @registry[channel_id]
        #else
          #@channel = @registry.issue
        #end
        #@channel.subscribe(self)
        #send_message command: 'init', channel: @channel.id
      else
        halt_with_error "Unknown command: #{command}"
      end
    end
  end

  def halt_with_error msg
    send_message 'error', msg: msg
    throw :halt
  end

  def send_message(command, params)
    s = JSON.generate([command, params])
    ws.send(s)
  end


  def with_rescue
    yield
  rescue => e
    puts "ERROR: #{e.class}: #{e.message}"
    puts e.backtrace
  end
end
