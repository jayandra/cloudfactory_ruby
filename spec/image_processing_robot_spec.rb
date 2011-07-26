# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::ImageProcessingRobot do
    context "create a image processing robot worker" do
      it "should create image processing robot worker for first station in Block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "image_processing_robot/block/create-worker-single-station", :record => :new_episodes do
          line = CF::Line.create("image_processing_robot_3","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::ImageProcessingRobot.create({:station => s, :image => ["{url}"], :sharpen => {:radius => "10"} })
            end
          end
          run = CF::Run.create(line, "image_processing_robot_run_3", [{"url"=> "http://wwwdelivery.superstock.com/WI/223/1527/PreviewComp/SuperStock_1527R-020214.jpg"}])
          output = run.final_output
          converted_url = output.first.final_output.first.processed_image_of_url
          File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url}").should eql(true)
          output.first.final_output.first.sharpen.radius.should eql(line.stations.first.worker.sharpen[:radius])
          line.stations.first.worker.image.should eql(["{url}"])
          line.stations.first.worker.class.should eql(CF::ImageProcessingRobot)
          line.stations.first.worker.reward.should eql(0)
          line.stations.first.worker.number.should eql(1)
        end
      end

      it "should create image processing robot worker for first station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "image_processing_robot/plain/create-worker-in-first-station", :record => :new_episodes do
          line = CF::Line.new("image_processing_robot_10","Digitization")
          input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::ImageProcessingRobot.create({:image => ["{url}"], :sharpen => {:radius => "10"} })
          line.stations.first.worker = worker

          run = CF::Run.create(line, "image_processing_robot_run_10", [{"url"=> "http://wwwdelivery.superstock.com/WI/223/1527/PreviewComp/SuperStock_1527R-020214.jpg"}])
          output = run.final_output
          converted_url = output.first.final_output.first.processed_image_of_url
          File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url}").should eql(true)
          output.first.final_output.first.sharpen.radius.should eql(line.stations.first.worker.sharpen[:radius])
          line.stations.first.worker.image.should eql(["{url}"])
          line.stations.first.worker.class.should eql(CF::ImageProcessingRobot)
          line.stations.first.worker.reward.should eql(0)
          line.stations.first.worker.number.should eql(1)
        end
      end
    end
  end
end