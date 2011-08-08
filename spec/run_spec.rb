require 'spec_helper'

module CF
  describe CF::Run do
    context "create a new run" do
      it "for a line in block dsl way" do
        VCR.use_cassette "run/block/create-run", :record => :new_episodes do
          # WebMock.allow_net_connect!
          line = CF::Line.create("Digarde-007","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
              end
            end
          end

          run = CF::Run.create(line, "runnamee1", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))

          line.title.should eq("Digarde-007")

          line.stations.first.input_formats.first['name'].should eq("Company")
          line.stations.first.input_formats.first['required'].should eq(true)

          line.stations[0].type.should eq("WorkStation")

          line.stations[0].worker.number.should eq(1)
          line.stations[0].worker.reward.should eq(20)

          line.stations[0].form.title.should eq("Enter text from a business card image")
          line.stations[0].form.instruction.should eq("Describe")

          line.stations[0].form.form_fields[0].label.should eq("First Name")
          line.stations[0].form.form_fields[0].field_type.should eq("SA")
          line.stations[0].form.form_fields[0].required.should eq(true)

          run.title.should eq("runnamee1")
          runfile = File.read(run.file)
          runfile.should == File.read(File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
        end
      end

      it "should create a production run for input data as plain data" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "run/block/create-run-without-file", :record => :new_episodes do
          line = CF::Line.create("Digitizard--11111000","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
              end
            end
          end
          run = CF::Run.create(line, "run-name--11111000", [{"Company"=>"Apple,Inc","Website"=>"Apple.com"},{"Company"=>"Google","Website"=>"google.com"}])
          run.input.should eql( [{"Company"=>"Apple,Inc","Website"=>"Apple.com"},{"Company"=>"Google","Website"=>"google.com"}])
        end
      end

      it "for an existing line" do
        VCR.use_cassette "run/block/create-run-of-an-existing-line", :record => :new_episodes do
          line = CF::Line.create("Digitizeard123","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
              end
            end
          end
          old_line = CF::Line.info(line.title)
          run = CF::Run.create(old_line,"Runusingline", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          run.title.should eq("Runusingline")

        end
      end

      it "for a line in a plain ruby way" do
        VCR.use_cassette "run/plain-ruby/create-run", :record => :new_episodes do
          line = CF::Line.new("Digitize--ard1", "Digitization")
          station = CF::Station.new({:type => "work"})
          line.stations station
          input_format_1 = CF::InputFormat.new({:name => "Company", :required => true, :valid_type => "general"})
          input_format_2 = CF::InputFormat.new({:name => "Website", :required => true, :valid_type => "url"})
          line.input_formats input_format_1
          line.input_formats input_format_2
          worker = CF::HumanWorker.new({:number => 1, :reward => 20})
          line.stations.first.worker = worker

          form = CF::TaskForm.new({:title => "Enter text from a business card image", :instruction => "Describe"})
          line.stations.first.form = form

          form_fields_1 = CF::FormField.new({:label => "First Name", :field_type => "SA", :required => "true"})
          line.stations.first.form.form_fields form_fields_1
          form_fields_2 = CF::FormField.new({:label => "Middle Name", :field_type => "SA"})
          line.stations.first.form.form_fields form_fields_2
          form_fields_3 = CF::FormField.new({:label => "Last Name", :field_type => "SA", :required => "true"})
          line.stations.first.form.form_fields form_fields_3

          run = CF::Run.create(line,"Run-in-plain-ruby-way", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))

          line.title.should eq("Digitize--ard1")
          line.stations.first.type.should eq("WorkStation")

          line.input_formats[0].name.should eq("Company")
          line.input_formats[0].required.should eq(true)
          line.input_formats[1].name.should eq("Website")
          line.input_formats[1].required.should eq(true)

          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.reward.should eql(20)

          line.stations.first.form.title.should eql("Enter text from a business card image")
          line.stations.first.form.instruction.should eql("Describe")

          line.stations.first.form.form_fields[0].label.should eql("First Name")
          line.stations.first.form.form_fields[0].field_type.should eql("SA")
          line.stations.first.form.form_fields[0].required.should eql(true)
          line.stations.first.form.form_fields[1].label.should eql("Middle Name")
          line.stations.first.form.form_fields[1].field_type.should eql("SA")
          line.stations.first.form.form_fields[2].label.should eql("Last Name")
          line.stations.first.form.form_fields[2].field_type.should eql("SA")
          line.stations.first.form.form_fields[2].required.should eql(true)
        end
      end

      it "should fetch result" do
        VCR.use_cassette "run/block/create-run-fetch-result", :record => :new_episodes do
          line = CF::Line.create("Digarde-00111111111","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CF::TaskForm.create({:station => s, :title => "Enter blah from card image", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
              end
            end
          end
          run = CF::Run.create(line, "run-name-result-0111111111", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          @final_output = run.final_output
          @final_output.first.meta_data['company'].should eql("Apple")
          @final_output.first.final_outputs.last['first-name'].should eql("Bob")
          @final_output.first.final_outputs.last['last-name'].should eql("Marley")
        end
      end

      xit "should fetch result of the specified station" do
        VCR.use_cassette "run/block/fetch-result-of-specified-station", :record => :new_episodes do
          line = CF::Line.create("Digitizeard-run-111","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CF::TaskForm.create({:station => s, :title => "Enter name of CEO :station", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
              end
            end
          end

          run = CF::Run.create(line, "run-name-run", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          @final_output = run.final_output
          @final_output.first.meta_data['company'].should eql("Apple")
          @final_output.first.final_outputs.last['first-name'].should eql("Bob")
          @final_output.first.final_outputs.last['last-name'].should eql("Marley")

          result_of_station_1 = run.output(:station => 1)
          result_of_station_1.first.meta_data['company'].should eql("Apple")
        end
      end

      it "should fetch result of the specified station with run title" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "run/block/fetch-result-with-title", :record => :new_episodes do
          line = CF::Line.create("keyword_matching_robot_result","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :type => "text_extraction_robot", :settings => {:url => ["{url}"]}})
            end
            CF::Station.create({:line => l, :type => "work"}) do |s1|
              CF::RobotWorker.create({:station => s1, :type => "keyword_matching_robot", :settings => {:content => ["{contents_of_url}"], :keywords => ["SaaS","see","additional","deepak","saroj"]}})
            end
          end
          run = CF::Run.create(line, "keyword_matching_robot_run_result", [{"url"=> "http://techcrunch.com/2011/07/26/with-v2-0-assistly-brings-a-simple-pricing-model-rewards-and-a-bit-of-free-to-customer-service-software"}])
          output = run.final_output
          output.first.final_output.first.included_keywords_count_in_contents_of_url.should eql(["3", "2", "2"])
          output.first.final_output.first.keyword_included_in_contents_of_url.should eql(["SaaS", "see", "additional"])
          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.reward.should eql(1)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:url => ["{url}"]})
          line.stations.first.worker.type.should eql("TextExtractionRobot")
          line.stations.last.worker.class.should eql(CF::RobotWorker)
          line.stations.last.worker.reward.should eql(1)
          line.stations.last.worker.number.should eql(1)
          line.stations.last.worker.settings.should eql({:content => ["{contents_of_url}"], :keywords => ["SaaS","see","additional","deepak","saroj"]})
          line.stations.last.worker.type.should eql("KeywordMatchingRobot")
          output_of_station_1 = CF::Run.output({:title => "keyword_matching_robot_run_result", :station => 1})
          output_of_station_2 = CF::Run.output({:title => "keyword_matching_robot_run_result", :station => 2})
          output_of_station_2['keyword_included_in_contents_of_url'].should eql(["SaaS", "see", "additional"])
          output_of_station_2['included_keywords_count_in_contents_of_url'].should eql(["3", "2", "2"])
        end
      end

      it "should create production run with invalid input_format for input" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "run/block/create-run-invalid-data", :record => :new_episodes do
          line = CF::Line.create("media_splitting_robot_3","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :type => "media_splitting_robot", :settings => {:url => ["http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"], :split_duration => "2", :overlapping_time => "1"}})
            end
          end
          run = CF::Run.create(line, "media_splitting_robot_run_3", [{"url_1"=> "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"}])
          run.errors.should eql(["Extra Headers in file: [url_1]", "Insufficient Headers in file: [url]"])
        end
      end

      it "should create production run with invalid data" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "run/block/create-run-invalid-file", :record => :new_episodes do
          line = CF::Line.create("media_splitting_robot_4","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :type => "media_splitting_robot", :settings => {:url => ["http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"], :split_duration => "2", :overlapping_time => "1"}})
            end
          end
          run = CF::Run.create(line, "media_splitting_robot_run_4", File.expand_path("../../fixtures/input_data/media_converter_robot.csv", __FILE__))
          run.errors.should eql(["Extra Headers in file: [url_1]", "Insufficient Headers in file: [url]"])

        end
      end

      it "should create production run with used title data" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "run/block/create-run-used-title", :record => :new_episodes do
          line = CF::Line.create("media_splitting_robot_5","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :type => "media_splitting_robot", :settings => {:url => ["http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"], :split_duration => "2", :overlapping_time => "1"}})
            end
          end
          run = CF::Run.create(line, "media_splitting_robot_run_5", [{"url"=> "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"}])
          run_1 = CF::Run.create(line, "media_splitting_robot_run_5", [{"url"=> "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"}])
          run_1.errors.should eql("[\"Title is already taken for this account\"]")
        end
      end

      it "should create production run and find created run" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "run/block/create-run-and-find", :record => :new_episodes do
          line = CF::Line.create("media_splitting_robot_6","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :type => "media_splitting_robot", :settings => {:url => ["http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"], :split_duration => "2", :overlapping_time => "1"}})
            end
          end
          run = CF::Run.create(line, "media_splitting_robot_run_6", [{"url"=> "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"}])
          found_run = CF::Run.find("media_splitting_robot_run_6")
          found_run.code.should eql(200)
          found_run.title.should eql("media_splitting_robot_run_6")
          found_run.line.title.should eql("media_splitting_robot_6")
          found_run.line.department.should eql("Digitization")
          found_run.status.should eql("active")
        end
      end

      it "should create production run and try to find run with unused title" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "run/block/find-run-with-unused-title", :record => :new_episodes do
          line = CF::Line.create("media_splitting_robot_7","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :type => "media_splitting_robot", :settings => {:url => ["http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"], :split_duration => "2", :overlapping_time => "1"}})
            end
          end
          run = CF::Run.create(line, "media_splitting_robot_run_7", [{"url"=> "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"}])
          found_run = CF::Run.find("unused_title")
          found_run.code.should eql(404)
          found_run.errors.should eql("Run document not found using selector: {:tenant_id=>BSON::ObjectId('4def16fa5511274d98000014'), \"account_id\"=>BSON::ObjectId('4def122255112748d7000003'), :title=>\"unused_title\"}")
        end
      end
    end
  end
end