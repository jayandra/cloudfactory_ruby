# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::MediaSplittingRobot do
    context "create a media splitting robot worker" do
      it "should create media splitting robot worker for first station in Block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "media_splitting_robot/block/create-worker-single-station", :record => :new_episodes do
          line = CF::Line.create("media_splitting_robot_3","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::MediaSplittingRobot.create({:station => s, :url => ["http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"], :split_duration => "2", :overlapping_time => "1"})
            end
          end
          run = CF::Run.create(line, "media_splitting_robot_run_3", [{"url"=> "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"}])
          output = run.final_output
          output.first.final_output.first.overlapping_time.should eql("1")
          output.first.final_output.first.split_duration.should eql("2")
          converted_url_1= output.first.final_output.first.splits_of_url.first.first
          converted_url_2= output.first.final_output.first.splits_of_url.first.last
          File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url_1}").should eql(true)
          File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url_2}").should eql(true)
          line.stations.first.worker.class.should eql(CF::MediaSplittingRobot)
          line.stations.first.worker.reward.should eql(5)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.url.should eql(["http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"])
          line.stations.first.worker.split_duration.should eql("2")
          line.stations.first.worker.overlapping_time.should eql("1")
        end
      end

      it "should create media splitting robot worker for first station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "media_splitting_robot/plain/create-worker-in-first-station", :record => :new_episodes do
          line = CF::Line.new("media_splitting_robot_5","Digitization")
          input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::MediaSplittingRobot.create({:url => ["http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"], :split_duration => "2", :overlapping_time => "1"})
          line.stations.first.worker = worker

          run = CF::Run.create(line, "media_splitting_robot_run_5", [{"url"=> "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"}])
          output = run.final_output
          output.first.final_output.first.overlapping_time.should eql("1")
          output.first.final_output.first.split_duration.should eql("2")
          converted_url_1= output.first.final_output.first.splits_of_url.first.first
          converted_url_2= output.first.final_output.first.splits_of_url.first.last
          File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url_1}").should eql(true)
          File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url_2}").should eql(true)
          line.stations.first.worker.class.should eql(CF::MediaSplittingRobot)
          line.stations.first.worker.reward.should eql(5)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.url.should eql(["http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"])
          line.stations.first.worker.split_duration.should eql("2")
          line.stations.first.worker.overlapping_time.should eql("1")
        end
      end
    end
  end
end