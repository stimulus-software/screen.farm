class Channel
  attr_reader :id, :listeners

  def initialize(id)
    @id = id
    @listeners = []
  end

  def subscribe(listener)
    @listeners << listener
  end

  def unsubscribe(listener)
    @listeners.delete(listener)
  end

  def active?
    @listeners.any?
  end

  def send_message(command, params)
    @listeners.each do |listener|
      listener.send_message(command, params)
    end
  end

  def show(params)
    send_message('show', params)
  end
end


