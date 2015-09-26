import 'channel'

class ChannelRegistry
  def initialize
    @collection = {}
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

  def issue(ws)
    id = generate_id
    @collection[id] = Channel.new(id, ws)
  end

  def [](id)
    @collection[id]
  end

  def all
    @collection.values
  end

  def all_active
    all.select(&:active?)
  end
end

