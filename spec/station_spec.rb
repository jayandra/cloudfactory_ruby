require 'spec_helper'

describe CloudFactory::Station do
  context "create a station" do
    it "the plain ruby way" do
      station = CloudFactory::Station.new("Station One")
      station.name.should eq("Station One")
    end

    it "using the block variable" do
      worker = CloudFactory::HumanWorker.new(2, 0.2)
      station = CloudFactory::Station.create("Station 1 Name") do |s|
        s.worker = worker
      end
      station.name.should eq("Station 1 Name")
      station.worker.should == worker
      station.worker.number.should == 2
      station.worker.reward.should == 0.2
    end
    
    it "using without the block variable" do
      human_worker = CloudFactory::HumanWorker.new(2, 0.2)
      station_1 = CloudFactory::Station.create("Station 1 Name") do 
        worker human_worker
      end
      station_1.name.should eq("Station 1 Name")
      station_1.worker.should == human_worker
      station_1.worker.number.should == 2
      station_1.worker.reward.should == 0.2
    end
  end
end