require 'spec_helper'

module CF
  describe CF::Run do
    context "create a new run" do
      it "for a line in block dsl way" do
        # VCR.use_cassette "run/block/create-run", :record => :new_episodes do
        WebMock.allow_net_connect!
          line = CF::Line.create("Digard-001111","Digitization") do |l|
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

          run = CF::Run.create(line, "runname11", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))

          line.title.should eq("Digard-001111")

          line.stations.first.input_formats.first.name.should eq("Company")
          line.stations.first.input_formats.first.required.should eq(true)

          line.stations[0].type.should eq("WorkStation")

          line.stations[0].worker.number.should eq(1)
          line.stations[0].worker.reward.should eq(20)

          line.stations[0].form.title.should eq("Enter text from a business card image")
          line.stations[0].form.instruction.should eq("Describe")

          line.stations[0].form.form_fields[0].label.should eq("First Name")
          line.stations[0].form.form_fields[0].field_type.should eq("SA")
          line.stations[0].form.form_fields[0].required.should eq(true)

          run.title.should eq("runname11")
          runfile = File.read(run.file)
          runfile.should == File.read(File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
        # end
      end

      it "should create a production run for input data as plain data" do
        WebMock.allow_net_connect!
        # VCR.use_cassette "run/block/create-run-without-file", :record => :new_episodes do
          line = CF::Line.create("Digitizard11111","Digitization") do |l|
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
          run = CF::Run.create(line, "run-name1111", [{"Company"=>"Apple,Inc","Website"=>"Apple.com"},{"Company"=>"Google","Website"=>"google.com"}])
          run.input.should eql( [{"Company"=>"Apple,Inc","Website"=>"Apple.com"},{"Company"=>"Google","Website"=>"google.com"}])
        # end
      end

      xit "for an existing line" do
        VCR.use_cassette "run/block/create-run-of-an-existing-line", :record => :new_episodes do
          line = CF::Line.create("Digitize Card","Digitization") do |l|
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::InputFormat.new({:station => s, :name => "Company", :required => true, :valid_type => "general"})
              CF::InputFormat.new({:station => s, :name => "Website", :required => true, :valid_type => "url"})
              CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
              end
            end
          end
          old_line = CF::Line.find(line.id)
          run = CF::Run.create(old_line,"Run Using Line", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          run.title.should eq("Run Using Line")
        end
      end

      xit "for a line in a plain ruby way" do
        VCR.use_cassette "run/plain-ruby/create-run", :record => :new_episodes do
          line = CF::Line.new("Digitize Card", "Digitization")
          station = CF::Station.new({:type => "work"})
          line.stations station
          input_format_1 = CF::InputFormat.new({:name => "Company", :required => true, :valid_type => "general"})
          input_format_2 = CF::InputFormat.new({:name => "Website", :required => true, :valid_type => "url"})
          line.stations.first.input_formats input_format_1
          line.stations.first.input_formats input_format_2
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

          run = CF::Run.create(line,"Run in plain ruby way", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))

          line.title.should eq("Digitize Card")
          line.stations.first.type.should eq("Work")

          line.stations.first.input_formats[0].name.should eq("Company")
          line.stations.first.input_formats[0].required.should eq(true)
          line.stations.first.input_formats[1].name.should eq("Website")
          line.stations.first.input_formats[1].required.should eq(true)

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
   
      xit "should fetch result" do
        VCR.use_cassette "run/block/create-run-fetch-result", :record => :new_episodes do
          line = CF::Line.create("Digitize Card","Digitization") do |l|
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::InputFormat.new({:station => s, :name => "Company", :required => true, :valid_type => "general"})
              CF::InputFormat.new({:station => s, :name => "Website", :required => true, :valid_type => "url"})
              CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CF::TaskForm.create({:station => s, :title => "Enter name of CEO", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
              end
            end
          end
          run = CF::Run.create(line, "run name", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          # debugger
          @final_output = run.final_output
          @final_output.first.meta_data['company'].should eql("Apple")
          @final_output.first.final_outputs.last['first-name'].should eql("Bob")
          @final_output.first.final_outputs.last['last-name'].should eql("Marley")
        end
      end
      
      xit "should fetch result of the specified station" do
        VCR.use_cassette "run/block/fetch-result-of-specified-station", :record => :new_episodes do
          line = CF::Line.create("Digitize Card","Digitization") do |l|
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::InputFormat.new({:station => s, :name => "Company", :required => true, :valid_type => "general"})
              CF::InputFormat.new({:station => s, :name => "Website", :required => true, :valid_type => "url"})
              CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CF::TaskForm.create({:station => s, :title => "Enter name of CEO :station", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
              end
            end
          end
          run = CF::Run.create(line, "run name", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          debugger
          @final_output = run.final_output
          @final_output.first.meta_data['company'].should eql("Apple")
          @final_output.first.final_outputs.last['first-name'].should eql("Bob")
          @final_output.first.final_outputs.last['last-name'].should eql("Marley")
          
          result_of_station_1 = run.output(:station => 1)
          # debugger
          # result_of_station_1.first.meta_data['company'].should eql("Apple")
        end
      end
    end
  end
end