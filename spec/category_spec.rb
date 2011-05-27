require 'spec_helper'

describe "CloudFactory::Category" do
  context "return category" do
    it "should get all the categories" do
      WebMock.allow_net_connect!
      CloudFactory.configure do |c|
        c.api_key = '5c99665131ad4044968de3ca0b984c8c0d45e9a2'
        c.email = 'manish.das@sprout-technology.com'
        c.api_url = "manishlaldas.lvh.me:3000/api/"
        c.api_version = "v1"
      end
      # VCR.use_cassette "category/all", :record => :new_episodes do
        categories = CloudFactory::Category.all
        categories.map(&:name).should include("Digitization")
        categories.map(&:name).should include("Data Processing")
        categories.map(&:name).should include("Survey")
      # end
    end
  end
  
  context "return lines of a category" do
    xit "should return all the lines of a particular category" do
      VCR.use_cassette "category/lines-of-category", :record => :new_episodes do
        5.times do |i|
          CloudFactory::Line.new("Digitize Card #{i}","4dc8ad6572f8be0600000001")
        end
        5.times do |i|
          CloudFactory::Line.new("Line Name #{i}","4dc8ad6572f8be0600000006")
        end
        lines_category_1 = CloudFactory::Category.get_lines_of_category("4dc8ad6572f8be0600000001")
        lines_category_2 = CloudFactory::Category.get_lines_of_category("4dc8ad6572f8be0600000006")
        debugger
        lines_category_1.map(&:name).should include("digitize-card-3")
      end
    end
  end
end
