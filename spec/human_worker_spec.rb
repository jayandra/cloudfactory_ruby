require 'spec_helper'

module CF
  describe CF::HumanWorker do
    context "create a worker" do
      it "the plain ruby way" do
        WebMock.allow_net_connect!
        line = CF::Line.create("human_worker", "Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line =>l, :type => "work"}) do |s|
            @worker = CF::HumanWorker.new({:station => s, :number => 2, :reward => 20})
          end
        end
        line.stations.first.type.should eql("WorkStation")
        line.stations.first.worker.number.should eql(2)
        line.stations.first.worker.reward.should eql(20)
      end
      
      it "in block DSL way with invalid data and should set the error" do
        WebMock.allow_net_connect!
        line = CF::Line.create("human_worker1", "Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line =>l, :type => "work"}) do |s|
            @worker = CF::HumanWorker.new({:station => s})
          end
        end
        line.stations.first.type.should eql("WorkStation")
        line.stations.first.worker.errors.should eql("[\"Reward is not a number\", \"Reward must not contain decimal places\"]")
      end
      
      it "in plain ruby way with invalid data and should set the error" do
        WebMock.allow_net_connect!
        line = CF::Line.new("human_worker2", "Digitization")
        input_format = CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"})
        line.input_formats input_format
        
        station = CF::Station.new({:type => "work"})
        line.stations station
        
        worker = CF::HumanWorker.new()
        line.stations.first.worker = worker
        
        line.stations.first.type.should eql("WorkStation")
        line.stations.first.worker.errors.should eql("[\"Reward is not a number\", \"Reward must not contain decimal places\"]")
      end
    end
  end
end