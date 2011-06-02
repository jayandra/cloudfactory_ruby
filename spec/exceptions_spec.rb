require 'spec_helper'

describe "Exceptions" do
  context "Line" do
    it "without name and department should raise ArgumentError" do
      WebMock.allow_net_connect!
      # VCR.use_cassette "lines/plain-ruby/create-station", :record => :new_episodes do
      line = CloudFactory::Line.new("Digitize Card", "Digitization")
      CloudFactory::Station.new({}).should_raise ArgumentError
      CloudFactory::Station.new({:line => line}).should_raise StationTypeMissing

      CloudFactory::HumanWorker.new({}).should_raise ArgumentError
    end
  end  
end
