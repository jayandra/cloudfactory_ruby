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
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
              end
            end
          end

          run = CF::Run.create(line, "runnamee1", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))

          line.title.should eq("Digarde-007")

          line.input_formats.first.name.should eq("Company")
          line.input_formats.first.required.should eq(true)

          line.stations[0].type.should eq("WorkStation")

          line.stations[0].worker.number.should eq(1)
          line.stations[0].worker.reward.should eq(20)

          line.stations[0].form.title.should eq("Enter text from a business card image")
          line.stations[0].form.instruction.should eq("Describe")

          line.stations[0].form.form_fields[0].label.should eq("First Name")
          line.stations[0].form.form_fields[0].field_type.should eq("short_answer")
          line.stations[0].form.form_fields[0].required.should eq(true)

          run.title.should eq("runnamee1")
          runfile = File.read(run.file)
          runfile.should == File.read(File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
        end
      end

      it "should create a production run for input data as Block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "run/block/create-run-without-file", :record => :new_episodes do
          line = CF::Line.create("Digitizard--11111000","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
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
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
              end
            end
          end
          run = CF::Run.create("Digitizeard123","Runusingline", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          run.title.should eq("Runusingline")

        end
      end

      it "just using line title" do
        VCR.use_cassette "run/block/create-run-using-line-title", :record => :new_episodes do
          line = CF::Line.create("line_title_run","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
              end
            end
          end
          run = CF::Run.create("line_title_run", "Runusinglinetitle", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          run.title.should eq("Runusinglinetitle")

        end
      end

      it "for a line in a plain ruby way" do
        VCR.use_cassette "run/plain-ruby/create-run", :record => :new_episodes do
          line = CF::Line.new("Digitize--ard1", "Digitization")
          input_format_1 = CF::InputFormat.new({:name => "Company", :required => true, :valid_type => "general"})
          input_format_2 = CF::InputFormat.new({:name => "Website", :required => true, :valid_type => "url"})
          line.input_formats input_format_1
          line.input_formats input_format_2
          
          station = CF::Station.new({:type => "work"})
          line.stations station
          
          worker = CF::HumanWorker.new({:number => 1, :reward => 20})
          line.stations.first.worker = worker

          form = CF::TaskForm.new({:title => "Enter text from a business card image", :instruction => "Describe"})
          line.stations.first.form = form

          form_fields_1 = CF::FormField.new({:label => "First Name", :field_type => "short_answer", :required => "true"})
          line.stations.first.form.form_fields form_fields_1
          form_fields_2 = CF::FormField.new({:label => "Middle Name", :field_type => "short_answer"})
          line.stations.first.form.form_fields form_fields_2
          form_fields_3 = CF::FormField.new({:label => "Last Name", :field_type => "short_answer", :required => "true"})
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
          line.stations.first.form.form_fields[0].field_type.should eql("short_answer")
          line.stations.first.form.form_fields[0].required.should eql(true)
          line.stations.first.form.form_fields[1].label.should eql("Middle Name")
          line.stations.first.form.form_fields[1].field_type.should eql("short_answer")
          line.stations.first.form.form_fields[2].label.should eql("Last Name")
          line.stations.first.form.form_fields[2].field_type.should eql("short_answer")
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
              CF::TaskForm.create({:station => s, :title => "Enter about CEO from card", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
              end
            end
          end
          run = CF::Run.create(line, "run-name-result-0111111111", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          # debugger
          @final_output = run.final_output
          @final_output.first['first-name'].should eql("Bob")
          @final_output.first['last-name'].should eql("Marley")
        end
      end

      it "should fetch result of the specified station with run title" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "run/block/fetch-result-with-title", :record => :new_episodes do
          line = CF::Line.create("keyword_matching_robot_result","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :type => "text_extraction_robot", :settings => {:url => ["{{url}}"]}})
            end
            CF::Station.create({:line => l, :type => "work"}) do |s1|
              CF::RobotWorker.create({:station => s1, :type => "keyword_matching_robot", :settings => {:content => ["{{contents_of_url}}"], :keywords => ["SaaS","see","additional","deepak","saroj", "iPhone"]}})
            end
          end
          run = CF::Run.create(line, "keyword_matching_robot_run_result", [{"url"=> "http://techcrunch.com/2011/07/26/with-v2-0-assistly-brings-a-simple-pricing-model-rewards-and-a-bit-of-free-to-customer-service-software"}, {"url"=> "http://techcrunch.com/2011/07/26/buddytv-iphone/"}])
          output = run.final_output
          output.first['included_keywords_count_in_contents_of_url'].should eql(["3", "2", "2"])
          output.first['keyword_included_in_contents_of_url'].should eql(["SaaS", "see", "additional"])
          output.last['included_keywords_count_in_contents_of_url'].should eql(["4"])
          output.last['keyword_included_in_contents_of_url'].should eql(["iPhone"])
          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.reward.should eql(0.5)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:url => ["{{url}}"]})
          line.stations.first.worker.type.should eql("TextExtractionRobot")
          line.stations.last.worker.class.should eql(CF::RobotWorker)
          line.stations.last.worker.reward.should eql(0.5)
          line.stations.last.worker.number.should eql(1)
          line.stations.last.worker.settings.should eql({:content => ["{{contents_of_url}}"], :keywords => ["SaaS","see","additional","deepak","saroj", "iPhone"]})
          line.stations.last.worker.type.should eql("KeywordMatchingRobot")
          output_of_station_1 = CF::Run.output({:title => "keyword_matching_robot_run_result", :station => 1})
          output_of_station_2 = CF::Run.output({:title => "keyword_matching_robot_run_result", :station => 2})
          output_of_station_2.first['keyword_included_in_contents_of_url'].should eql(["SaaS", "see", "additional"])
          output_of_station_2.first['included_keywords_count_in_contents_of_url'].should eql(["3", "2", "2"])
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
          run_1.errors.should eql(["Title is already taken for this account"])
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
          found_run.errors.should eql("Run document not found using selector: {:tenant_id=>BSON::ObjectId('4def16fa5511274d98000014'), :title=>\"unused_title\"}")
        end
      end
    end
  
    context "check run progress and resume run" do
      it "should check the progress" do
        VCR.use_cassette "run/block/run-progress", :record => :new_episodes do
        # WebMock.allow_net_connect!
          line = CF::Line.create("progress_run_line","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
            end
          end
          run = CF::Run.create(line, "progress_run", [{"url"=> "http://www.sprout-technology.com"}])
          progress = run.progress
          progress_1 = CF::Run.progress("progress_run")
          progress.should eql(progress_1)
          progress.progress.should eql(100)
        end
      end
      
      it "should get the progress details" do
        VCR.use_cassette "run/block/run-progress-detail", :record => :new_episodes do
        # WebMock.allow_net_connect!
          line = CF::Line.create("progress_run_line_1","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
            end
          end
          run = CF::Run.create(line, "progress_run_1", [{"url"=> "http://www.sprout-technology.com"}])
          progress = run.progress_details
          progress_1 = CF::Run.progress_details("progress_run_1")
          progress.should eql(progress_1)
          progress.total.progress.should eql(100)
          progress.total.units.should eql(1)
        end
      end

      it "should get the progress details for multiple stations" do
        VCR.use_cassette "run/block/run-progress-detail-for-multiple-station", :record => :new_episodes do
          # WebMock.allow_net_connect!
          line = CF::Line.create("progress_run_line_2","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :type => "text_extraction_robot", :settings => {:url => ["{{url}}"]}})
            end
            CF::Station.create({:line => l, :type => "work"}) do |s1|
              CF::RobotWorker.create({:station => s1, :type => "keyword_matching_robot", :settings => {:content => ["{{contents_of_url}}"], :keywords => ["SaaS","see","additional","deepak","saroj"]}})
            end
          end
          run = CF::Run.create(line, "progress_run_2", [{"url"=> "http://techcrunch.com/2011/07/26/with-v2-0-assistly-brings-a-simple-pricing-model-rewards-and-a-bit-of-free-to-customer-service-software"}])
          progress = run.progress_details
          progress_1 = CF::Run.progress_details("progress_run_2")
          progress.should eql(progress_1)
          progress.total.progress.should eql(100)
          progress.total.units.should eql(1)
        end
      end
    end
    
    context "get run" do
      it "should return all the runs for an account" do
        VCR.use_cassette "run/block/get-run-account", :record => :new_episodes do
        # WebMock.allow_net_connect!
          line = CF::Line.create("progress_run_line_3","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
            end
          end
          run = CF::Run.create(line, "progress_run_3", [{"url"=> "http://www.sprout-technology.com"}])
          
          line_1 = CF::Line.create("progress_run_line_31","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
            end
          end
          run_1 = CF::Run.create(line_1, "progress_run_31", [{"url"=> "http://www.sprout-technology.com"}])
          
          line_2 = CF::Line.create("progress_run_line_32","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
            end
          end
          run_2 = CF::Run.create(line_2, "progress_run_32", [{"url"=> "http://www.sprout-technology.com"}])
          
          got_run = CF::Run.all
          got_run.first.line.title.should eql("keyword_matching_robot_result")
          got_run.first.title.should eql("keyword_matching_robot_run_result")
          got_run.last.line.title.should eql("digarde-007")
          got_run.last.title.should eql("runnamee1")
        end
      end
      
      it "should return all the runs for a line" do
        VCR.use_cassette "run/block/get-run-line", :record => :new_episodes do
        # WebMock.allow_net_connect!
          line = CF::Line.create("progress_run_line_11","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
            end
          end
          run = CF::Run.create(line, "progress_run_11", [{"url"=> "http://www.sprout-technology.com"}])
          run_1 = CF::Run.create(line, "progress_run_12", [{"url"=> "http://www.sprout-technology.com"}])
          run_2 = CF::Run.create(line, "progress_run_13", [{"url"=> "http://www.sprout-technology.com"}])
          got_run = CF::Run.all("progress_run_line_11")
          got_run[0].title.should eql("progress_run_11")
          got_run[1].title.should eql("progress_run_12")
          got_run[2].title.should eql("progress_run_13")
        end
      end
    end
    
    context "create a run with insufficient balance and" do
      it "should resume run" do
        VCR.use_cassette "run/block/resume-run", :record => :new_episodes do
        # WebMock.allow_net_connect!
        # change account available_balance to 10 cents
          line = CF::Line.create("resume_run_line","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
              end
            end
          end
          run = CF::Run.create(line, "resume_run", [{"Company"=>"Apple,Inc","Website"=>"Apple.com"},{"Company"=>"Google","Website"=>"google.com"}])
          run.errors.should eql("run is created but could not be started because of lack of funds please refund your account to continue the run see your email for more information")
          # debugger
          # Change account available_balance to 200000 cents
          resumed_run = CF::Run.resume("resume_run")
          resumed_run.code.should eql(200)
          resumed_run.status.should eql("resumed")
          resumed_run.title.should eql("resume_run")
        end
      end
    end
  end
end