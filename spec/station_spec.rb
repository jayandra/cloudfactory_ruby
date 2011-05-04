require 'spec_helper'

describe CloudFactory::Station do
  context "create a station" do
    it "the plain ruby way" do
      station = CloudFactory::Station.new("Station One")
      station.name.should eq("Station One")
    end
  end
end