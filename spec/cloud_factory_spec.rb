require 'cloud_factory/line'

describe CloudFactory::Line do
  context "create a line" do
    it "the plain ruby way" do
      line = CloudFactory::Line.new("Digitize Card")
      line.name.should eq("Digitize Card")
    end
    
    it "using block with accessor flavor" do
      line_1 = CloudFactory::Line.new do |l|
        l.name = "Digitize Addresses"
      end
      line_1.name.should eq("Digitize Addresses")
    end

    xit "using block with methods flavor" do
      line = CloudFactory::Line.new("Digitize Addresses") do 
        @worker = CloudFactory::Worker.new()
      end
      line_1.name.should eq("Digitize Addresses")
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
