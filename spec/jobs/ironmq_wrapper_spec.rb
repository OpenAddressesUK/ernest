require 'spec_helper'

describe IronMqWrapper do

  before(:each) do
    @wrapper = IronMqWrapper.new("ironmq_wrapper_test")
    @mock_queue = @wrapper.queue
    @mock_queue.post({ "some": "json"}.to_json)
  end

  after(:each) do
    @mock_queue.clear
  end

  it "picks a message from the queue", :vcr do
    expect(@wrapper.get.body).to eq({ "some": "json"}.to_json)
  end

  it "deletes messages from the queue", :vcr do
    @wrapper.get
    @wrapper.delete
    expect(@wrapper.get).to eq(nil)
  end

  it "retries gets if there's an error", :vcr do
    allow(@wrapper).to receive(:sleep) { nil }
    expect(@mock_queue).to receive(:get).exactly(5).times.and_raise("Error")
    expect(@mock_queue).to receive(:get).and_call_original

    @wrapper.get
  end

  it "retries deletes if there's an error", :vcr do
    @msg = @wrapper.get

    allow(@wrapper).to receive(:sleep) { nil }
    expect(@msg).to receive(:delete).exactly(5).times.and_raise("Error")
    expect(@msg).to receive(:delete).and_call_original

    @wrapper.delete
  end

end
