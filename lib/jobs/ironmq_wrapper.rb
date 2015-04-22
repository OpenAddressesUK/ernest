require 'iron_mq'
require 'dotenv'

Dotenv.load

class IronMqWrapper

  attr_accessor :queue

  def initialize(queue_name)
    @queue_name = queue_name
  end

  def get
    @msg = queue.get
    @msg
  end

  def delete
    @msg.delete
  end

  def ironmq
    @@ironmq ||= IronMQ::Client.new(token: JiffyBag['IRON_MQ_TOKEN'], project_id: JiffyBag['IRON_MQ_PROJECT_ID'], host: 'mq-aws-eu-west-1.iron.io')
  end

  def queue
    @queue ||= ironmq.queue(@queue_name)
  end

end
