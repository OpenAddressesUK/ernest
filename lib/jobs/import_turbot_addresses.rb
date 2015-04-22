require_relative './ironmq_wrapper'

class ImportTurbotAddresses
  def self.perform
    queue = IronMqWrapper.new(JiffyBag['IRON_MQ_TURBOT_QUEUE'])

    @msg = queue.get

    while !@msg.nil? do
      json = JSON.parse @msg.body

      unless json['snapshot_id'] == 'draft'

        ImportAddresses.create_address json['data']
      end
      queue.delete
      @msg = queue.get
    end
  end

end
