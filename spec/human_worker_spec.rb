require 'spec_helper'

module CF
  describe CF::HumanWorker do
    context "create a worker" do
      xit "the plain ruby way" do
        line = CF::Line.create("Digitize Card", "Digitization") do |l|
          l.stations = CF::Station.create(l, :type => "work") do |s|
            @worker = CF::HumanWorker.new(s, 2, 20)
            s.worker = @worker
          end
        end
        
        station = line.stations.first.get_station
        # debugger
        #         station.worker.number.should eq(2)
        #         station.worker.reward.should eq(0.2)
      end
    end
  end
end