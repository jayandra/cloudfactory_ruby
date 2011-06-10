require 'spec_helper'

describe "Exceptions" do
  context "Line" do
    xit "without name and department should raise ArgumentError" do
      WebMock.allow_net_connect!
      # VCR.use_cassette "lines/plain-ruby/create-station", :record => :new_episodes do
      line = CF::Line.new("Digitize Card", "Digitization")
      CF::Station.new({}).should_raise ArgumentError
      CF::Station.new({:line => line}).should_raise StationTypeMissing

      CF::HumanWorker.new({}).should_raise ArgumentError
    end
  end  
end
