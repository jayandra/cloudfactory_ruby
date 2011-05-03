require 'spec_helper'

describe CloudFactory::Line do
  let(:input_header) { CloudFactory::InputHeader.new({:label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"}) }
  
  context "create a line" do
    it "the plain ruby way" do
      line = CloudFactory::Line.new("Digitize Card")
      line.name.should eq("Digitize Card")
    end
    
    it "using block with variable" do
      line = CloudFactory::Line.create("Digitize Card") do |l|
        l.input_headers << input_header
      end
      line.name.should eq("Digitize Card")
      line.input_headers.size.should eq(1)
      line.input_headers.first.should == input_header
    end

    it "using block without variable" do
      line = CloudFactory::Line.create("Digitize Card") do
        input_headers << input_header
      end
      line.name.should eq("Digitize Card")
      line.input_headers.size.should eq(1)
      line.input_headers.first.should == input_header
    end
    
    context "with 1 station" do
      it "create with a new station" do
        line_1 = CloudFactory::Line.create("Digitize Card") do |l|
          l.stations << CloudFactory::Station.new("Station 1 Name")
        
          # l.station = Station.new("Station 1 Name") do |station|
          #   station.workers = worker
          #   station.instruction = instruction
          # end
        end
        line_1.name.should eq("Digitize Card")
        line_1.stations.size.should eq(1)
        line_1.stations.first.name.should eq("Station 1 Name")
      end
    end
  end
  
end
