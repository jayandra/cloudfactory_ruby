require 'spec_helper'

describe CloudFactory::Category do
  it "should get all the categories" do
    categories = CloudFactory::Category.all
    categories[0]._id.should eq("4db9319f703cf14825000001")
    categories[0].name.should eq("Digitization")
    categories[1]._id.should eq("4db9319f703cf14825000002")
    categories[1].name.should eq("Data Processing")
  end
end
