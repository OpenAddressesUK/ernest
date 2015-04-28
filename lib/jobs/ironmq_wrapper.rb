require 'iron_mq'
require 'dotenv'

Dotenv.load

class IronMqWrapper

  attr_accessor :queue

  def initialize(queue_name)
    @queue_name = queue_name
  end

  def get
    @msg = call_with_retry(lambda { queue.get })
    @msg
  end

  def delete
    call_with_retry(lambda { @msg.delete })
  end

  def ironmq
    @@ironmq ||= IronMQ::Client.new(token: JiffyBag['IRON_MQ_TOKEN'], project_id: JiffyBag['IRON_MQ_PROJECT_ID'], host: 'mq-aws-eu-west-1.iron.io')
  end

  def queue
    @queue ||= ironmq.queue(@queue_name)
  end

  def call_with_retry(code)
    limit ||= 5
    tries ||= 0
    code.call
  rescue
    if (tries += 1) <= limit
      seconds = 5 * tries
      $stderr.puts "Hit error, trying again in #{seconds} seconds"
      sleep seconds
      retry
    else
      $stderr.puts "Giving up"
    end
  end

end
