require 'spec_helper'

describe CF::Account do
  it "should get the account info" do
    # WebMock.allow_net_connect!
    VCR.use_cassette "account/info", :record => :new_episodes do
      account_info = CF::Account.info
      account_info.name.should eql("manish")
    end
  end
end