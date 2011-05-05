require 'spec_helper'

describe CloudFactory do
  context "configuration" do
    it "be able to configure the api key" do
      CloudFactory.configure do |c|
        c.api_key = "1323d12a25cb9bb9f1f201b75bf81a037f599aa9"
      end
      CloudFactory.api_key.should eq("1323d12a25cb9bb9f1f201b75bf81a037f599aa9")
      CloudFactory.remote_uri.should eq("http://cloudfactory.com/api/v1/")
    end
  end
end