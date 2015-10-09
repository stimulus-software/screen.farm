class WebsocketHandler
  attr_reader :ws, :registry
  attr_accessor :sid, :sco, :pco, :fid

  def initialize(ws, registry)
    @ws = ws
    @registry = registry
  end

  def run
    @ws.on :message do |event|
      with_rescue do
        m = JSON.parse(event.data)
        handle_command(*m)
        registry.print_stats
      end
    end

    @ws.on :close do |event|
      with_rescue do
        p [:close, event.code, event.reason]
        @ws = nil
        if sid
          registry.unsubscribe(fid, sco, sid, self)
        end
        registry.print_stats
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

        self.sid = params.sid or halt_with_error "sid missing in connect"
        self.sco = params.sco
        self.pco = params.pco
        self.fid = params.fid
        (pco || fid) or halt_with_error "pco and fid missing in connect"

        if pco
          self.fid = registry.lookup_pco(pco) or
            halt_with_error "pco invalid"
          self.sco = registry.issue_sco(fid)
        else
          self.sco ||= registry.issue_sco(fid)
        end
        registry.subscribe(fid, sco, sid, self)
        send_message 'connected', fid: fid, sco: sco

        self.pco = registry.issue_paircode fid
        send_message 'paircode', pco: pco

      when 'sco'
        registry.unsubscribe(fid, sco, sid, self)
        registry.remove_sco(fid, sco)
        self.sco = params.sco
        registry.subscribe(fid, sco, sid, self)

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
