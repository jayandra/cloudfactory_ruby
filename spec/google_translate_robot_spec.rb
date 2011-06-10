require 'spec_helper'

module CF
  describe CF::GoogleTranslateRobot do
    context "create a google translator worker" do
      xit "the plain ruby way" do
        WebMock.allow_net_connect!
        line = CF::Line.new("Digitize Card","Digitization")
        station = CF::Station.new(line, :type => "work")
        worker = CF::GoogleTranslateRobot.create(station)
        old_line = CF::Line.find(line.id)
        line.stations.first.worker.number.should eq(1)
        line.stations.first.worker.reward.should eq(nil)
      end
    end
  end
end