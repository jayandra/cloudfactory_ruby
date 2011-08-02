# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::RobotWorker do
    context "create a concept tagging robot worker" do
      it "should create concept tagging robot worker for first station in Block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "robot_worker/concept_tagging_robot/block/create-worker-single-station", :record => :new_episodes do
          line = CF::Line.create("concept_tagging_robot","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :type => "concept_tagging_robot", :settings => {:url => ["{url}"]}})
            end
          end
          run = CF::Run.create(line, "concept_tagging_robot_run", [{"url"=>"www.mosexindex.com"}])
          output = run.final_output
          output.first.final_output.first.concept_tagging_of_url.should eql(["Canada", "English language"])
          output.first.final_output.first.concept_tagging_relevance_of_url.should eql([89.5153, 79.0912])
          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.reward.should eql(1)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:url => ["{url}"]})
          line.stations.first.worker.type.should eql("ConceptTaggingRobot")
        end
      end

      it "should create content_scraping_robot worker for first station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "robot_worker/concept_tagging_robot/plain-ruby/create-worker-in-first-station", :record => :new_episodes do
          line = CF::Line.new("concept_tagging_robot_1","Digitization")
          input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::RobotWorker.create({:type => "concept_tagging_robot", :settings => {:url => ["{url}"]}})
          line.stations.first.worker = worker

          run = CF::Run.create(line, "concept_tagging_robot_run_1", [{"url"=>"www.mosexindex.com"}])
          output = run.final_output
          output.first.final_output.first.concept_tagging_of_url.should eql(["Canada", "English language"])
          output.first.final_output.first.concept_tagging_relevance_of_url.should eql([89.5153, 79.0912])
          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.reward.should eql(1)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:url => ["{url}"]})
          line.stations.first.worker.type.should eql("ConceptTaggingRobot")
        end
      end
    end
  end
end