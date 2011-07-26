# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::KeywordMatchingRobot do
    context "create a keyword matching robot worker" do
      it "should create keyword matching robot worker for first station in Block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "keyword_matching_robot/block/create-worker-single-station", :record => :new_episodes do
          line = CF::Line.create("keyword_matching_robot_1","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::TextExtractionRobot.create({:station => s, :url => ["{url}"]})
            end
            CF::Station.create({:line => l, :type => "work"}) do |s1|
              CF::KeywordMatchingRobot.create({:station => s1, :content => ["{contents_of_url}"], :keywords => "SaaS,see,additional,deepak,saroj"})
            end
          end
          run = CF::Run.create(line, "keyword_matching_robot_run_1", [{"url"=> "http://techcrunch.com/2011/07/26/with-v2-0-assistly-brings-a-simple-pricing-model-rewards-and-a-bit-of-free-to-customer-service-software"}])
          output = run.final_output
          output.first.final_output.first.keyword_included_in_contents_of_url.should eql(["SaaS", "see", "additional"])
          output.first.final_output.first.keywords.should eql("SaaS,see,additional,deepak,saroj")
          line.stations.first.worker.class.should eql(CF::TextExtractionRobot)
          line.stations.first.worker.reward.should eql(100)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.url.should eql(["{url}"])
          line.stations.last.worker.class.should eql(CF::KeywordMatchingRobot)
          line.stations.last.worker.reward.should eql(200)
          line.stations.last.worker.number.should eql(1)
          line.stations.last.worker.content.should eql(["{contents_of_url}"])
          line.stations.last.worker.keywords.should eql("SaaS,see,additional,deepak,saroj")
        end
      end

      it "should create keyword matching robot worker for first station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "keyword_matching_robot/plain/create-worker-in-first-station", :record => :new_episodes do
          line = CF::Line.new("keyword_matching_robot_2","Digitization")
          input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::TextExtractionRobot.create({:url => ["{url}"]})
          line.stations.first.worker = worker
          
          station_1 = CF::Station.new({:type => "work"})
          line.stations station
          
          worker = CF::KeywordMatchingRobot.create({:content => ["{contents_of_url}"], :keywords => "SaaS,see,additional,deepak,saroj"})
          line.stations.last.worker = worker

          run = CF::Run.create(line, "keyword_matching_robot_run_1", [{"url"=> "http://techcrunch.com/2011/07/26/with-v2-0-assistly-brings-a-simple-pricing-model-rewards-and-a-bit-of-free-to-customer-service-software"}])
          output = run.final_output
          output.first.final_output.first.keyword_included_in_contents_of_url.should eql(["SaaS", "see", "additional"])
          output.first.final_output.first.keywords.should eql("SaaS,see,additional,deepak,saroj")
          line.stations.first.worker.class.should eql(CF::TextExtractionRobot)
          line.stations.first.worker.reward.should eql(100)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.url.should eql(["{url}"])
          line.stations.last.worker.class.should eql(CF::KeywordMatchingRobot)
          line.stations.last.worker.reward.should eql(200)
          line.stations.last.worker.number.should eql(1)
          line.stations.last.worker.content.should eql(["{contents_of_url}"])
          line.stations.last.worker.keywords.should eql("SaaS,see,additional,deepak,saroj")
        end
      end
    end
  end
end