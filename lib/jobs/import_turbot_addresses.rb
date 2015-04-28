require 'iron_mq'
require 'dotenv'

Dotenv.load

class ImportTurbotAddresses
  def self.perform
    @msg = queue.get

    while !@msg.nil? do
      begin
        json = JSON.parse @msg.body
      rescue JSON::ParserError
        json = @msg.body.reverse.chomp('"').reverse.chomp('"').gsub("\\\"", '"')
      end

      unless json['snapshot_id'] == 'draft'

        ImportAddresses.create_address json['data']
      end
      @msg.delete
      @msg = queue.get
    end
  end

  def self.ironmq
    @@ironmq ||= IronMQ::Client.new(token: JiffyBag['IRON_MQ_TOKEN'], project_id: JiffyBag['IRON_MQ_PROJECT_ID'], host: 'mq-aws-eu-west-1.iron.io')
  end

  def self.queue
    ironmq.queue(JiffyBag['IRON_MQ_TURBOT_QUEUE'])
  end
end
