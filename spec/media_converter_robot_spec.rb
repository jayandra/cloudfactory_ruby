require 'spec_helper'

module CF
  describe CF::MediaConverterRobot do
    context "create a media converter robot worker" do
      it "should create media_converter_robot worker for first station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "media_converter_robot/block/create-worker-in-first-station", :record => :new_episodes do
          line = CF::Line.new("media-line","Digitization")

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

          worker = CF::MediaConverterRobot.create({:station => line.stations.first, :url => "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov", :to => "mpg", :audio_quality => "320", :video_quality => "3"})

          form = CF::TaskForm.new({:title => "Enter text", :instruction => "Describe"})
          line.stations.first.form = form

          form_fields = CF::FormField.new({:label => "Description", :field_type => "SA", :required => "true"})
          line.stations.first.form.form_fields form_fields

          run = CF::Run.create(line, "media-converter-robot", [{"url"=> "www.s3.amazon.com/converted/20110518165230/ten.mpg", "to" => "mpg", "audio_quality" => "320", "video_quality" => "3",  "meta_data_text"=>"media"}])

          @final_output = run.final_output
          line.stations.first.worker.number.should eq(1)
          @final_output.first.final_outputs.first['audio_quality'].should eql("320")
          @final_output.first.final_outputs.first['video_quality'].should eql("3")
          @final_output.first.final_outputs.first['to'].should eql("mpg")
          converted_url = @final_output.first.final_outputs.first['url']
          File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url}").should eql(true)
        end
      end

      it "should create media_converter_robot worker for first station in a plain ruby way without passing station parameter within the syntax" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "media_converter_robot/block/create-worker-in-plain-ruby-way", :record => :new_episodes do
          line = CF::Line.new("media-line-2","Digitization")

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

          worker = CF::MediaConverterRobot.create({:url => "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov", :to => "mpg", :audio_quality => "320", :video_quality => "3"})
          line.stations.first.worker = worker

          form = CF::TaskForm.new({:title => "Enter text", :instruction => "Describe"})
          line.stations.first.form = form

          form_fields = CF::FormField.new({:label => "Description", :field_type => "SA", :required => "true"})
          line.stations.first.form.form_fields form_fields

          run = CF::Run.create(line, "media-converter-robot-2", [{"url"=> "www.s3.amazon.com/converted/20110518165230/ten.mpg", "to" => "mpg", "audio_quality" => "320", "video_quality" => "3",  "meta_data_text"=>"media"}])

          @final_output = run.final_output
          line.stations.first.worker.number.should eq(1)
          @final_output.first.final_outputs.first['audio_quality'].should eql("320")
          @final_output.first.final_outputs.first['video_quality'].should eql("3")
          @final_output.first.final_outputs.first['to'].should eql("mpg")
          converted_url = @final_output.first.final_outputs.first['url']
          File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url}").should eql(true)
        end
      end

      it "should create media_converter_robot worker for multiple station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "media_converter_robot/block/create-worker-multiple-station", :record => :new_episodes do
          line = CF::Line.create("media-line-4","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
            CF::InputFormat.new({:line => l, :name => "url", :required => true, :valid_type => "url"})
            CF::InputFormat.new({:line => l, :name => "to", :required => false, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "audio_quality", :required => false, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "video_quality", :required => false, :valid_type => "general"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CF::TaskForm.create({:station => s, :title => "Enter-video-url-about-the-CEO", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
                CF::FormField.new({:form => i, :label => "ceo_video", :field_type => "LA", :required => "true"})
              end
            end
          end

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::MediaConverterRobot.create({:url => ["{ceo_video}"], :to => "mpg", :audio_quality => "320", :video_quality => "3"})
          line.stations.last.worker = worker

          form = CF::TaskForm.new({:title => "Enter-text-media-converter", :instruction => "Describe"})
          line.stations.last.form = form

          form_fields = CF::FormField.new({:label => "Description", :field_type => "SA", :required => "true"})
          line.stations.last.form.form_fields form_fields

          run = CF::Run.create(line, "media-converter-robot-4", [{"Company" => "Apple", "Website" => "www.apple.com", "url"=> "www.s3.amazon.com/converted/20110518165230/ten.mpg", "to" => "mpg", "audio_quality" => "320", "video_quality" => "3",  "meta_data_text"=>"media"}])

          # debugger
          @final_output = run.final_output
          line.stations.last.worker.number.should eq(1)
          @final_output.first.final_outputs.first['audio_quality'].should eql("320")
          @final_output.first.final_outputs.first['video_quality'].should eql("3")
          @final_output.first.final_outputs.first['to'].should eql("mpg")
        end
      end

      it "should create media_converter_robot in block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "media_converter_robot/block/create-worker-block-dsl-way", :record => :new_episodes do
          line = CF::Line.create("media-line-5","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :required => true, :valid_type => "url"})
            CF::InputFormat.new({:line => l, :name => "to", :required => false, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "audio_quality", :required => false, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "video_quality", :required => false, :valid_type => "general"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::MediaConverterRobot.create({:station => s, :url => "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov", :to => "mpg", :audio_quality => "320", :video_quality => "3"})
              CF::TaskForm.create({:station => s, :title => "Enter text", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "Description", :field_type => "SA", :required => "true"})
              end
            end
          end

          run = CF::Run.create(line, "media-converter-robot-5", [{"url"=> "www.s3.amazon.com/converted/20110518165230/ten.mpg", "to" => "mpg", "audio_quality" => "320", "video_quality" => "3",  "meta_data_text"=>"media"}])

          @final_output = run.final_output
          line.stations.first.worker.number.should eq(1)
          @final_output.first.final_outputs.first['audio_quality'].should eql("320")
          @final_output.first.final_outputs.first['video_quality'].should eql("3")
          @final_output.first.final_outputs.first['to'].should eql("mpg")
          converted_url = @final_output.first.final_outputs.first['url']
          File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url}").should eql(true)
        end
      end
    end
  end
end
