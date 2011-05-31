require 'spec_helper'

module CloudFactory
  describe CloudFactory::GoogleTranslateRobot do
    context "create a google translator worker" do
      xit "the plain ruby way" do
        WebMock.allow_net_connect!
        line = CloudFactory::Line.new("Digitize Card","Digitization")
        station = CloudFactory::Station.new(line, :type => "work")
        worker = CloudFactory::GoogleTranslateRobot.create(station)
        old_line = CloudFactory::Line.find(line.id)
        line.stations.first.worker.number.should eq(1)
        line.stations.first.worker.reward.should eq(nil)
      end
    end
  end
end