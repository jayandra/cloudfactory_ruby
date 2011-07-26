# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::ConceptTaggingRobot do
    context "create a concept tagging robot worker" do
      it "should create concept tagging robot worker for first station in Block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "concept_tagging_robot/block/create-worker-single-station", :record => :new_episodes do
          line = CF::Line.create("concept_tagging_robot_1","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::ConceptTaggingRobot.create({:station => s, :url => ["{url}"]})
            end
          end
          run = CF::Run.create(line, "concept_tagging_robot_run_1", [{"url"=> "www.pornhub.com"}])
          output = run.final_output
          output.first.final_output.first.concept_tagging_of_url.should eql(["Pornography", "Pornography addiction", "Pornographic actor", "Amateur pornography", "Internet", "Reality pornography", "Pornographic film"])
          output.first.final_output.first.concept_tagging_relevance_of_url.should eql([96.2012, 80.8069, 71.2139, 66.0961, 63.461999999999996, 58.9256, 54.413999999999994])
          line.stations.first.worker.class.should eql(CF::ConceptTaggingRobot)
          line.stations.first.worker.reward.should eql(500)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.url.should eql(["{url}"])
        end
      end

      it "should create content_scraping_robot worker for first station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "concept_tagging_robot/plain/create-worker-in-first-station", :record => :new_episodes do
          line = CF::Line.new("concept_tagging_robot_2","Digitization")
          input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::ConceptTaggingRobot.create({:url => ["{url}"]})
          line.stations.first.worker = worker

          run = CF::Run.create(line, "concept_tagging_robot_run_2", [{"url"=> "www.pornhub.com"}])
          output = run.final_output
          output.first.final_output.first.concept_tagging_of_url.should eql(["Pornography", "Pornography addiction", "Pornographic actor", "Amateur pornography", "Internet", "Reality pornography", "Pornographic film"])
          output.first.final_output.first.concept_tagging_relevance_of_url.should eql([96.2012, 80.8069, 71.2139, 66.0961, 63.461999999999996, 58.9256, 54.413999999999994])
          line.stations.first.worker.class.should eql(CF::ConceptTaggingRobot)
          line.stations.first.worker.reward.should eql(500)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.url.should eql(["{url}"])
        end
      end
    end
  end
end