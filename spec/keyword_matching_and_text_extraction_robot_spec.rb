# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::RobotWorker do
    context "create a keyword matching robot worker and text extraction robot" do
      it "should create keyword matching robot worker for first station in Block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "robot_worker/keyword_matching_robot/block/create-worker-single-station", :record => :new_episodes do
          line = CF::Line.create("keyword_matching_robot","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :type => "text_extraction_robot", :settings => {:url => ["{{url}}"]}})
            end
            CF::Station.create({:line => l, :type => "work"}) do |s1|
              CF::RobotWorker.create({:station => s1, :type => "keyword_matching_robot", :settings => {:content => ["{{contents_of_url}}"], :keywords => ["SaaS","see","additional","deepak","saroj"]}})
            end
          end
          run = CF::Run.create(line, "keyword_matching_robot_run", [{"url"=> "http://techcrunch.com/2011/07/26/with-v2-0-assistly-brings-a-simple-pricing-model-rewards-and-a-bit-of-free-to-customer-service-software"}])
          output = run.final_output
          output.first.final_output.first.included_keywords_count_in_contents_of_url.should eql(["3", "2", "2"])
          output.first.final_output.first.keyword_included_in_contents_of_url.should eql(["SaaS", "see", "additional"])
          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.reward.should eql(0.5)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:url => ["{{url}}"]})
          line.stations.first.worker.type.should eql("TextExtractionRobot")
          line.stations.last.worker.class.should eql(CF::RobotWorker)
          line.stations.last.worker.reward.should eql(0.5)
          line.stations.last.worker.number.should eql(1)
          line.stations.last.worker.settings.should eql({:content => ["{{contents_of_url}}"], :keywords => ["SaaS","see","additional","deepak","saroj"]})
          line.stations.last.worker.type.should eql("KeywordMatchingRobot")
        end
      end

      it "should create keyword matching robot worker for first station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "robot_worker/keyword_matching_robot/plain-ruby/create-worker-in-first-station", :record => :new_episodes do
          line = CF::Line.new("keyword_matching_robot_1","Digitization")
          input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::RobotWorker.create({:type => "text_extraction_robot", :settings => {:url => ["{{url}}"]}})
          line.stations.first.worker = worker
          
          station_1 = CF::Station.new({:type => "work"})
          line.stations station
          
          worker = CF::RobotWorker.create({:type => "keyword_matching_robot", :settings => {:content => ["{{contents_of_url}}"], :keywords => ["SaaS","see","additional","deepak","saroj"]}})
          line.stations.last.worker = worker

          run = CF::Run.create(line, "keyword_matching_robot_run_1", [{"url"=> "http://techcrunch.com/2011/07/26/with-v2-0-assistly-brings-a-simple-pricing-model-rewards-and-a-bit-of-free-to-customer-service-software"}])
          output = run.final_output
          output.first.final_output.first.included_keywords_count_in_contents_of_url.should eql(["3", "2", "2"])
          output.first.final_output.first.keyword_included_in_contents_of_url.should eql(["SaaS", "see", "additional"])
          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.reward.should eql(0.5)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:url => ["{{url}}"]})
          line.stations.first.worker.type.should eql("TextExtractionRobot")
          line.stations.last.worker.class.should eql(CF::RobotWorker)
          line.stations.last.worker.reward.should eql(0.5)
          line.stations.last.worker.number.should eql(1)
          line.stations.last.worker.settings.should eql({:content => ["{{contents_of_url}}"], :keywords => ["SaaS","see","additional","deepak","saroj"]})
          line.stations.last.worker.type.should eql("KeywordMatchingRobot")
        end
      end
    end
  end
end