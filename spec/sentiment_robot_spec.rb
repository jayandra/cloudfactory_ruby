# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::RobotWorker do
    context "create a sentiment robot worker" do
      it "should create content_scraping_robot worker for first station in Block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "robot_worker/sentiment_robot/block/create-worker-single-station", :record => :new_episodes do
          line = CF::Line.create("sentiment_robot","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :settings => {:document => ["{{url}}"], :sanitize => true}, :type => "sentiment_robot"})
            end
          end
          run = CF::Run.create(line, "sentiment_robot_run", [{"url"=> "http://www.thehappyguy.com/happiness-self-help-book.html"}])
          output = run.final_output
          output.first.final_output.first.sentiment_of_url.should eql("positive")
          output.first.final_output.first.sentiment_relevance_of_url.should eql(24.0408)
          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.reward.should eql(0.5)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:document => ["{{url}}"], :sanitize => true})
          line.stations.first.worker.type.should eql("SentimentRobot")
        end
      end

      it "should create content_scraping_robot worker for first station in plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "robot_worker/sentiment_robot/plain_ruby/create-worker-single-station", :record => :new_episodes do
          line = CF::Line.new("sentiment_robot_1","Digitization")
          input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker =  CF::RobotWorker.new({:settings => {:document => ["{{url}}"], :sanitize => true}, :type => "sentiment_robot"})
          line.stations.first.worker = worker

          run = CF::Run.create(line, "sentiment_robot_run_1", [{"url"=> "http://www.thehappyguy.com/happiness-self-help-book.html"}])
          output = run.final_output
          output.first.final_output.first.sentiment_of_url.should eql("positive")
          output.first.final_output.first.sentiment_relevance_of_url.should eql(24.0408)
          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.reward.should eql(0.5)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:document => ["{{url}}"], :sanitize => true})
          line.stations.first.worker.type.should eql("SentimentRobot")
        end
      end
    end
  end
end