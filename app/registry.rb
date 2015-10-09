import 'channel'

class Registry
  def initialize
    @collection = {}
    @farms = {}
    @screens = {}
    @last_sco = {}
  end

  def generate_id
    set = ('a'..'z').to_a
    a = %w(a e i y o u)
    b = set - a
    #n = %w(n m)
    4.times.map {
      [
        [a, b, a, b],
        [b, a, b, a],
        [b, a, a, b],
      ].sample.map(&:sample).join
    }.join('-')
  end

  def issue
    self[generate_id]
  end

  def [](id)
    type, *rest = id.split ":"
    if type == 's'
      sid = *rest
    else
      fid, sco = rest
      sid = @farms[fid][sco] or
        raise "sid not found by fid & sco: #{fid}, #{sco} [id: #{id}]"
    end
    @screens[sid] or raise "Channel not found by sid: #{sid} [id: #{id}]"
  end

  def subscribe(fid, sco, sid, listener)
    @farms[fid] ||= { }
    @farms[fid][sco] = sid
    @screens[sid] ||= Channel.new(sid)
    @screens[sid].subscribe(listener)
  end

  def issue_sco(fid)
    @last_sco[fid] ||= 0
    @last_sco[fid] += 1
    @last_sco[fid].to_s
  end


end

