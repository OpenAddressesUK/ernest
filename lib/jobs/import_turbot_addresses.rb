require_relative './ironmq_wrapper'

class ImportTurbotAddresses
  def self.perform
    queue = IronMqWrapper.new(JiffyBag['IRON_MQ_TURBOT_QUEUE'])

    @msg = queue.get

    while !@msg.nil? do
      begin
        json = JSON.parse @msg.body
      rescue JSON::ParserError
        json = @msg.body.reverse.chomp('"').reverse.chomp('"').gsub("\\\"", '"')
      end

      unless json['snapshot_id'] == 'draft'

        if json['data']['saon'] && json['data']['provenance']['activity']['derived_from'].first['type'] == "inference"
          json['data']['saon'] = nil
        end

        ImportAddresses.create_address json['data']
      end
      queue.delete
      @msg = queue.get
    end
  end

end
