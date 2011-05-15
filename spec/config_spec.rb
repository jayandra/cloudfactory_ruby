require 'spec_helper'

describe CloudFactory do
  context "configuration" do
    it "be able to configure the api key" do
      CloudFactory.configure do |c|
        c.api_key = "6bbf1bf58c56119aa22801484a8700071c35fe1d"
      end
      CloudFactory.api_key.should eq("6bbf1bf58c56119aa22801484a8700071c35fe1d")
      CloudFactory.api_url.should eq("manishdas.lvh.me:3000/api/")
      CloudFactory.api_version.should eq("v1")
    end
  end
end