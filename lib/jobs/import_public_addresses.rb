require 'iron_mq'
require 'dotenv'

Dotenv.load

class ImportPublicAddresses
  def self.perform
    @msg = queue.get

    while !@msg.nil? do
      ImportAddresses.create_address JSON.parse(@msg.body)

      @msg.delete
      @msg = queue.get
    end
  end

  def self.ironmq
    @@ironmq ||= IronMQ::Client.new(token: JiffyBag['IRON_MQ_TOKEN'], project_id: JiffyBag['IRON_MQ_PROJECT_ID'], host: 'mq-aws-eu-west-1.iron.io')
  end

  def self.queue
    ironmq.queue(JiffyBag['IRON_MQ_QUEUE'])
  end
end
