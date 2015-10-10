import 'channel'

class Registry
  def initialize
    @screens = {}
  end

  def [](id)
    # s:<sid>
    # f:<fid>:<sco>
    type, *rest = id.split ":"
    if type == 's'
      sid = *rest
    else
      fid, sco = rest
      sid = redis.get("farm:#{fid}:sco:#{sco}:sid") or
        raise "sid not found by fid & sco: #{fid}, #{sco} [id: #{id}]"
    end
    @screens[sid]
  end

  def subscribe(fid, sco, sid, listener)
    redis.sadd "farm:#{fid}:scos", sco
    redis.setex "farm:#{fid}:sco:#{sco}:sid", 7*24*60*60, sid
    @screens[sid] ||= Channel.new(sid)
    @screens[sid].subscribe(listener)
  end

  def remove_sco(fid, sco)
    redis.srem "farm:#{fid}:scos", sco
    redis.del "farm:#{fid}:sco:#{sco}:sid"
  end

  def unsubscribe(fid, sco, sid, listener)
    @screens.delete(sid)
  end

  def channels_in_farm(fid)
    redis.smembers("farm:#{fid}:scos").map do |sco|
      puts "MEMBER: #{sco}"
      sid = redis.get("farm:#{fid}:sco:#{sco}:sid")
      puts "SID: #{sid}"
      if sid && (channel = @screens[sid])
        Hashie::Mash.new(
          sco: sco,
          sid: sid,
          channel: channel
        )
      end
    end.compact
  end

  def issue_sco(fid)
    generate_code(1, '')
  end

  def issue_paircode(fid)
    pco = generate_paircode
    redis.setex "pco:#{pco}", 10*60, fid
    pco
  end

  def generate_paircode
    generate_code(2, '')
  end

  def generate_code(sets = 4, delim = '-')
    set = ('a'..'z').to_a
    a = %w(a e i y o u)
    b = set - a
    #n = %w(n m)
    sets.times.map {
      [
        [a, b, a, b],
        [b, a, b, a],
        [b, a, a, b],
      ].sample.map(&:sample).join
    }.join(delim)
  end

  def lookup_pco(pco)
    redis.get "pco:#{pco}"
  end

  def redis
    $redis
  end

  def print_stats
    puts "STATS: #{@screens.size} screens connected"
  end
end

