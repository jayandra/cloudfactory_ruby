require 'spec_helper'

module CF
  describe CF::RobotWorker do
    context "create a media converter robot worker" do
      xit "should create media_converter_robot worker for first station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "robot_worker/media_converter_robot/plain-ruby/create-worker-in-first-station", :record => :new_episodes do
          line = CF::Line.new("media_converter_robot","Digitization")

          input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
          line.input_formats input_format

          input_format_1 = CF::InputFormat.new({:name => "to", :required => false, :valid_type => "general"})
          line.input_formats input_format_1

          input_format_2 = CF::InputFormat.new({:name => "audio_quality", :required => false, :valid_type => "general"})
          line.input_formats input_format_2

          input_format_3 = CF::InputFormat.new({:name => "video_quality", :required => false, :valid_type => "general"})
          line.input_formats input_format_3

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::RobotWorker.create({:type => "media_converter_robot", :settings => {:url => "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov", :to => "mpg", :audio_quality => "320", :video_quality => "3"}})
          line.stations.first.worker = worker

          form = CF::TaskForm.new({:title => "Enter text", :instruction => "Describe"})
          line.stations.first.form = form

          form_fields = CF::FormField.new({:label => "Description", :field_type => "SA", :required => "true"})
          line.stations.first.form.form_fields form_fields

          run = CF::Run.create(line, "media_converter_robot_run", [{"url"=> "www.s3.amazon.com/converted/20110518165230/ten.mpg", "to" => "mpg", "audio_quality" => "320", "video_quality" => "3",  "meta_data_text"=>"media"}])
          @final_output = run.final_output
          line.stations.first.worker.number.should eq(1)
          @final_output.first.final_output.first.audio_quality.should eql("320")
          @final_output.first.final_output.first.video_quality.should eql("3")
          @final_output.first.final_output.first.to.should eql("mpg")
          converted_url = @final_output.first.final_output.first.converted_file_from_url.first
          File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url}").should eql(true)
        end
      end
      
      xit "should create media_converter_robot in block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "robot_worker/media_converter_robot/block/create-worker-block-dsl-way", :record => :new_episodes do
          line = CF::Line.create("media_converter_robot_1","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :required => true, :valid_type => "url"})
            CF::InputFormat.new({:line => l, :name => "to", :required => false, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "audio_quality", :required => false, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "video_quality", :required => false, :valid_type => "general"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :type => "media_converter_robot", :settings => {:url => "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov", :to => "mpg", :audio_quality => "320", :video_quality => "3"}})
            end
          end

          run = CF::Run.create(line, "media_converter_robot_run_1", [{"url"=> "www.s3.amazon.com/converted/20110518165230/ten.mpg", "to" => "mpg", "audio_quality" => "320", "video_quality" => "3",  "meta_data_text"=>"media"}])

          @final_output = run.final_output
          line.stations.first.worker.number.should eq(1)
          @final_output.first.final_output.first.audio_quality.should eql("320")
          @final_output.first.final_output.first.video_quality.should eql("3")
          @final_output.first.final_output.first.to.should eql("mpg")
          converted_url = @final_output.first.final_output.first.converted_file_from_url.first
          File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url}").should eql(true)
        end
      end
    end
  end
end
