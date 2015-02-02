ENV['IRON_MQ_QUEUE'] = "addresses_test"
require 'spec_helper'

describe ImportAddresses do

  before(:each) do
    @mock_queue = ImportAddresses.queue

    10.times do |n|
      @message = {
        "saon"=>nil,
        "paon"=>n,
        "street"=>"Downing Street",
        "locality"=>nil,
        "town"=>"London",
        "postcode"=>"SW1A 2AA",
        "provenance"=> {
          "activity"=> {
            "executed_at"=>"2015-01-30T17:57:51+00:00",
            "processing_scripts"=>"https://github.com/OpenAddressesUK/sorting_office",
            "derived_from" => [
              {
                "type"=>"userInput",
                "input"=>"10 Downing Street, London, SW1A 2AA",
                "inputted_at"=>"2015-01-30T17:57:51+00:00",
                "processing_script"=> "https://github.com/OpenAddressesUK/sorting_office/tree/0fff78c71a170e2264faef7962e19f99a645c1d0/lib/sorting_office/address.rb"
              },
              {
                "type"=>"Source",
                "urls"=>["http://alpha.openaddressesuk.org/postcodes/Uxm2vc"],
                "downloaded_at"=>"2015-01-30T17:57:51+00:00",
                "processing_script"=>"https://github.com/OpenAddressesUK/sorting_office/tree/0fff78c71a170e2264faef7962e19f99a645c1d0/lib/models/postcode.rb"
              },
              {
                "type"=>"Source",
                "urls"=>["http://alpha.openaddressesuk.org/towns/qyHZe2"],
                "downloaded_at"=>"2015-01-30T17:57:51+00:00",
                "processing_script"=>"https://github.com/OpenAddressesUK/sorting_office/tree/0fff78c71a170e2264faef7962e19f99a645c1d0/lib/models/town.rb"
              },
              {
                "type"=>"Source",
                "urls"=>["http://alpha.openaddressesuk.org/streets/Gq5142"],
                "downloaded_at"=>"2015-01-30T17:57:51+00:00",
                "processing_script"=>"https://github.com/OpenAddressesUK/sorting_office/tree/0fff78c71a170e2264faef7962e19f99a645c1d0/lib/models/street.rb"
              }
            ]
          }
        }
      }.to_json

      @mock_queue.post(@message)
    end
  end

  it "picks the correct number of messages from the queue" do
    ImportAddresses.perform

    expect(Address.count).to eq(10)
  end

  it "deletes messages from the queue" do
    ImportAddresses.perform

    expect(ImportAddresses.queue.get).to eq(nil)
  end

  it "generates the correct provenance" do
    ImportAddresses.perform

    activity = Address.first.activity

    expect(activity.executed_at).to eq(DateTime.parse("2015-01-30T17:57:51+00:00"))
    expect(activity.processing_script).to eq("https://github.com/OpenAddressesUK/sorting_office")
    expect(activity.derivations.count).to eq(4)

    expect(activity.derivations.first.entity.kind).to eq("userInput")
    expect(activity.derivations.first.entity.input).to eq("10 Downing Street, London, SW1A 2AA")
    expect(activity.derivations.first.entity.activity.processing_script).to eq("https://github.com/OpenAddressesUK/sorting_office/tree/0fff78c71a170e2264faef7962e19f99a645c1d0/lib/sorting_office/address.rb")
    expect(activity.derivations.first.entity.activity.executed_at).to eq(DateTime.parse("2015-01-30T17:57:51+00:00"))

    expect(activity.derivations[1].entity.kind).to eq("url")
    expect(activity.derivations[1].entity.input).to eq("http://alpha.openaddressesuk.org/postcodes/Uxm2vc")
  end

end
