require 'cloud_factory/line'

describe CloudFactory::Line do
  it "creating a new line" do
    line = CloudFactory::Line.new("Digitize Card")
    line.name.should eq("Digitize Card")
  end
end
