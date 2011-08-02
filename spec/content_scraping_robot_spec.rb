# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::RobotWorker do
    context "create a content scraping robot worker" do
      it "should create content_scraping_robot worker for first station in Block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "robot_worker/content_scraping_robot/block/create-worker-single-station", :record => :new_episodes do
          line = CF::Line.create("content_scraping_robot","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :type => "content_scraping_robot", :settings => {:document => ["http://www.sprout-technology.com"], :query => "1st 2 links after Sprout products"}})
            end
          end
          run = CF::Run.create(line, "content_scraping_robot_run", [{"url"=> "http://www.sprout-technology.com"}])
          
          output = run.final_output
          output.first.final_output.first.scraped_link_from_document.should eql([["http://www.cloudfactory.com", "http://www.bizcardarmy.com"]])
          output.first.final_output.first.query.should eql("1st 2 links after Sprout products")

          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.reward.should eql(10)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:document => ["http://www.sprout-technology.com"], :query => "1st 2 links after Sprout products"})
          line.stations.first.worker.type.should eql("ContentScrapingRobot")
        end
      end

      it "should create content_scraping_robot worker for first station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "robot_worker/content_scraping_robot/plain-ruby/create-worker-in-first-station", :record => :new_episodes do
          line = CF::Line.new("content_scraping_robot_run_1","Digitization")
          input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::RobotWorker.create({:type => "content_scraping_robot", :settings => {:document => ["http://www.sprout-technology.com"], :query => "1st 2 links after Sprout products"}})
          line.stations.first.worker = worker

          run = CF::Run.create(line, "content_scraping_robot_run_1", [{"url"=> "http://www.sprout-technology.com"}])
          
          output = run.final_output
          output.first.final_output.first.scraped_link_from_document.should eql([["http://www.cloudfactory.com", "http://www.bizcardarmy.com"]])
          output.first.final_output.first.query.should eql("1st 2 links after Sprout products")

          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.reward.should eql(10)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:document => ["http://www.sprout-technology.com"], :query => "1st 2 links after Sprout products"})
          line.stations.first.worker.type.should eql("ContentScrapingRobot")
        end
      end
    end
  end
end