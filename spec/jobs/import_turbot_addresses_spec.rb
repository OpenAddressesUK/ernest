ENV['IRON_MQ_TURBOT_QUEUE'] = "addresses_test"
require 'spec_helper'

describe ImportTurbotAddresses do

  context "with user inputted addresses" do

    before(:each) do
      @mock_queue = IronMqWrapper.new(ENV['IRON_MQ_TURBOT_QUEUE']).queue

      10.times do |n|
        @message = {
          "type" => "bot.record",
          "bot_name" => "turbot-bot",
          "snapshot_id" => 1,
          "data" => {
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
          },
          "data_type" => "address",
          "identifying_fields" => nil
        }.to_json
        @mock_queue.post(@message)
      end
    end

    it "picks the correct number of messages from the queue", :vcr do
      ImportTurbotAddresses.perform

      expect(Address.count).to eq(10)
    end

    it "deletes messages from the queue", :vcr do
      ImportTurbotAddresses.perform

      expect(@mock_queue.get).to eq(nil)
    end

    it "generates the correct provenance", :vcr do
      ImportTurbotAddresses.perform

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

  context "with inferred addresses" do
    before(:each) do
      @mock_queue = IronMqWrapper.new(ENV['IRON_MQ_TURBOT_QUEUE']).queue

      10.times do |n|
        @message = {
          "type" => "bot.record",
          "bot_name" => "turbot-bot",
          "snapshot_id" => 1,
          "data" => {
            "saon"=>"PM HOUSE",
            "paon"=>n,
            "street"=>"Downing Street",
            "locality"=>nil,
            "town"=>"London",
            "postcode"=>"SW1A 2AA",
            "provenance"=> {
              "activity"=> {
                "executed_at"=>"2015-04-20T12:33:11.843+00:00",
                "processing_scripts"=>"https://github.com/OpenAddressesUK/jess",
                "derived_from" => [
                  {
                    "type"=>"inference",
                    "inferred_from"=>["http://ernest.openaddressesuk.org/addresses/2813808","http://ernest.openaddressesuk.org/addresses/1032935"],
                    "inferred_at"=>"2015-04-20T12:33:11.844+00:00",
                    "processing_script"=> "https://github.com/OpenAddressesUK/jess/blob/ea74748d324efda47054e465cdfe76bdc4f8c5df/lib/jess.rb"
                  }
                ]
              }
            }
          },
          "data_type" => "address",
          "identifying_fields" => nil
        }.to_json

        @mock_queue.post(@message)
      end
    end

    it "generates the correct provenance for inferred addresses", :vcr do
      ImportTurbotAddresses.perform

      activity = Address.first.activity

      expect(activity.executed_at).to eq("2015-04-20T12:33:11.00+00:00")
      expect(activity.processing_script).to eq("https://github.com/OpenAddressesUK/jess")
      expect(activity.derivations.count).to eq(1)

      expect(activity.derivations.first.entity.kind).to eq("inference")
      expect(activity.derivations.first.entity.input).to eq("http://ernest.openaddressesuk.org/addresses/2813808,http://ernest.openaddressesuk.org/addresses/1032935")
      expect(activity.derivations.first.entity.activity.executed_at).to eq(Time.parse "2015-04-20T12:33:11.00+00:00")
      expect(activity.derivations.first.entity.activity.processing_script).to eq("https://github.com/OpenAddressesUK/jess/blob/ea74748d324efda47054e465cdfe76bdc4f8c5df/lib/jess.rb")
    end

    it "removes saons from inferred addresses", :vcr do
      ImportTurbotAddresses.perform

      expect(Address.first.saon.label).to eq(nil)
    end
  end

  context "with bad address data" do
    before(:each) do
      @mock_queue = IronMqWrapper.new(ENV['IRON_MQ_TURBOT_QUEUE']).queue

      10.times do |n|
        @message = "{\"type\":\"bot.record\",\"bot_name\":\"companies_house_3\",\"snapshot_id\":\"5571\",\"data\":{\"saon\":null,\"paon\":\"10\",\"street\":\"London Road\",\"locality\":null,\"town\":\"London\",\"postcode\":\"E13 0DN\",\"valid_at\":\"2014-03-31T00:00:00+00:00\",\"provenance\":{\"activity\":{\"executed_at\":\"2015-04-21T10:55:20+00:00\",\"processing_scripts\":\"http://github.com/oa-bots/companies_house\",\"derived_from\":[{\"type\":\"Source\",\"urls\":[\"http://download.companieshouse.gov.uk/BasicCompanyData-2015-04-01-part4_5.zip\"],\"downloaded_at\":\"2015-04-21T10:54:59+00:00\",\"processing_script\":\"https://github.com/oa-bots/companies_house/tree/aa971c7b191c716f9ec6304af6910bc1d64db621/scraper.rb\"},{\"type\":\"Source\",\"urls\":[\"http://alpha.openaddressesuk.org/streets/NjqzJv\"],\"downloaded_at\":\"2015-04-21T10:55:20+00:00\",\"processing_script\":\"https://github.com/oa-bots/companies_house/tree/aa971c7b191c716f9ec6304af6910bc1d64db621/scraper.rb\"},{\"type\":\"Source\",\"urls\":[\"http://alpha.openaddressesuk.org/towns/4194LO\"],\"downloaded_at\":\"2015-04-21T10:55:20+00:00\",\"processing_script\":\"https://github.com/oa-bots/companies_house/tree/aa971c7b191c716f9ec6304af6910bc1d64db621/scraper.rb\"},{\"type\":\"Source\",\"urls\":[\"http://alpha.openaddressesuk.org/postcodes/EdcN8s\"],\"downloaded_at\":\"2015-04-21T10:55:20+00:00\",\"processing_script\":\"https://github.com/oa-bots/companies_house/tree/aa971c7b191c716f9ec6304af6910bc1d64db621/scraper.rb\"}]}}},\"data_type\":\"address\",\"identifying_fields\":null}"

        @mock_queue.post(@message)
      end
    end

    it "picks the correct number of messages from the queue", :vcr do
      ImportTurbotAddresses.perform

      expect(Address.count).to eq(10)
    end
  end

  context "with addresses with URIs" do
    before(:each) do
      @mock_queue = IronMqWrapper.new(ENV['IRON_MQ_TURBOT_QUEUE']).queue

      10.times do |n|
        @message = {
          "type" => "bot.record",
          "bot_name" => "turbot-bot",
          "snapshot_id" => 1,
          "data" => {
            "uprn"=>"2003322#{n}",
            "uri"=>"https://alpha.openaddressesuk.org/addresses/#{n}",
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
          },
          "data_type" => "address",
          "identifying_fields" => nil
        }.to_json

        @mock_queue.post(@message)
      end

    end

    it "creates addresses correctly", :vcr do
      ImportTurbotAddresses.perform

      expect(Address.first.uprn.label).to eq("20033220")
      expect(Address.first.uri.label).to eq("https://alpha.openaddressesuk.org/addresses/0")
    end
  end

end
