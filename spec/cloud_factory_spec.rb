require 'spec_helper'

describe CloudFactory::Line do
  context "create a line" do
    it "the plain ruby way" do
      line = CloudFactory::Line.new("Digitize Card")
      line.name.should eq("Digitize Card")
    end
    
    it "using block with accessor flavor" do
      input_header = CloudFactory::InputHeader.new({:label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
      line = CloudFactory::Line.new("Digitize Card") do |l|
        l.input_headers << input_header
      end
      line.name.should eq("Digitize Card")
      puts "IN #{line.input_headers}"
      line.input_headers.size.should eq(1)
      line.input_headers.first.should == input_header
    end

    it "using block with methods flavor" do
      line = CloudFactory::Line.new("Digitize Addresses") do 
        @worker = CloudFactory::HumanWorker.new(2, 0.2)
      end
      line.name.should eq("Digitize Addresses")
    end
    
    context "with 1 station" do
      xit "create with a new station" do
        line_1 = CloudFactory::Line.new do |l|
          l.name = "Digitize Addresses"
          l.station = Station.new("Station 1 Name") do |station|
            station.workers = worker
            station.instruction = instruction
          end
        end
        line_1.name.should eq("Digitize Addresses")
      end
    end
  end
  
end
