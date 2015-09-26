import 'channel'

class ChannelRegistry
  def initialize
    @counter = 0
    @collection = {}
  end

  def next_id
    @counter += 1
    @counter.to_s
  end

  def issue(ws)
    id = next_id
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

