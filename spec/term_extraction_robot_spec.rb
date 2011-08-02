# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::RobotWorker do
    context "create a Term Extraction robot worker" do
      it "should create content_scraping_robot worker for first station in Block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "robot_worker/term_extraction_robot/block/create-worker-single-station", :record => :new_episodes do
          line = CF::Line.create("term_extraction","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :settings => {:url => ["{url}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
            end
          end
          run = CF::Run.create(line, "term_extraction_run", [{"url"=> "http://www.sprout-technology.com"}])
          output = run.final_output
          output.first.final_output.first.keyword_relevance_of_url.should eql([99.7991, 95.6566, 83.2383, 79.39450000000001, 76.0281])
          output.first.final_output.first.keywords_of_url.should eql(["Web App", "web application", "Web App Development", "Web App Management", "world-class web development"])
          output.first.final_output.first.max_retrieve.should eql("5")
          output.first.final_output.first.show_source_text.should eql("true")
          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.reward.should eql(8)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:url => ["{url}"], :max_retrieve => 5, :show_source_text => true})
          line.stations.first.worker.type.should eql("TermExtractionRobot")
        end
      end

      it "should create content_scraping_robot worker for first station in plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "robot_worker/term_extraction_robot/plain-ruby/create-worker-single-station", :record => :new_episodes do
          line = CF::Line.new("term_extraction_1","Digitization")
          input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker =  CF::RobotWorker.create({:settings => {:url => ["{url}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
          line.stations.first.worker = worker

          run = CF::Run.create(line, "term_extraction_run_1", [{"url"=> "http://www.sprout-technology.com"}])
          output = run.final_output
          output.first.final_output.first.keyword_relevance_of_url.should eql([99.7991, 95.6566, 83.2383, 79.39450000000001, 76.0281])
          output.first.final_output.first.keywords_of_url.should eql(["Web App", "web application", "Web App Development", "Web App Management", "world-class web development"])
          output.first.final_output.first.max_retrieve.should eql("5")
          output.first.final_output.first.show_source_text.should eql("true")
          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.reward.should eql(8)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:url => ["{url}"], :max_retrieve => 5, :show_source_text => true})
          line.stations.first.worker.type.should eql("TermExtractionRobot")
        end
      end
    end
  end
end