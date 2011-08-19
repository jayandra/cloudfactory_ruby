require 'spec_helper'

describe CF::RobotWorker do
  context "create a robot worker" do
    it "should only display the attributes which are mentioned in to_s method" do
      VCR.use_cassette "robot_worker/block/display-to_s", :record => :new_episodes do
      # WebMock.allow_net_connect!
        line = CF::Line.create("display_entity_extraction_robot","Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "text", :valid_type => "general", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :type => "entity_extraction_robot", :settings => {:document => ["Franz Kafka and George Orwell are authors. Ludwig Von Beethoven and Mozart are musicians. China and Japan are countries"]}})
          end
        end
        line.stations.first.worker.to_s.should eql("{:number => #{line.stations.first.worker.number}, :reward => #{line.stations.first.worker.reward}, :type => EntityExtractionRobot, :settings => #{line.stations.first.worker.settings}, :errors => }")
      end
    end
  end
end