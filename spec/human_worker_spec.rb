require 'spec_helper'

module CloudFactory
  describe CloudFactory::HumanWorker do
    context "create a worker" do
      it "the plain ruby way" do
        WebMock.allow_net_connect!

        line = CloudFactory::Line.new("Newest Line", "Digitization") 
        station = CloudFactory::Station.new(line, :type => "work") 
        worker = CloudFactory::HumanWorker.new(station, 2, 0.2)

        got_line = CloudFactory::Line.find(line.id)
        debugger
        line.stations.first.worker.number.should eq(2)
        line.stations.first.worker.reward.should eq(0.2)
      end
    end
  end
end