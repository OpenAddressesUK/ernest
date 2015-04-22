require_relative './ironmq_wrapper'

class ImportPublicAddresses
  def self.perform
    queue = IronMqWrapper.new(JiffyBag['IRON_MQ_QUEUE'])

    @msg = queue.get

    while !@msg.nil? do
      ImportAddresses.create_address JSON.parse(@msg.body)

      queue.delete
      @msg = queue.get
    end
  end

end
