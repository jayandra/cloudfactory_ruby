require 'spec_helper'

describe CloudFactory do
  context "configuration" do
    it "be able to configure the api key" do
      API_CONFIG = YAML.load_file(File.expand_path("../../fixtures/api_credentials.yml", __FILE__))
      CloudFactory.configure do |config|
        config.api_version = API_CONFIG['api_version']
        config.api_url = API_CONFIG['api_url']
        config.api_key = API_CONFIG['api_key']
      end
      
      CloudFactory.api_key.should eq(API_CONFIG['api_key'])
      CloudFactory.api_url.should eq(API_CONFIG['api_url'])
      CloudFactory.api_version.should eq(API_CONFIG['api_version'])
    end
  end
end