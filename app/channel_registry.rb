require 'channel'

class ChannelRegistry
  def initialize
    @counter = 0
  end

  def get_next
    @counter += 1
    @counter
  end

  def issue
    Channel.new(get_next)
  end
end

