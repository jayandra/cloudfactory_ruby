require 'spec_helper'

module CloudFactory
  describe CloudFactory::Run do
    context "create a new run" do
      it "for a line in block dsl way" do
        VCR.use_cassette "run/block/create-run", :record => :new_episodes do
          line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
            CloudFactory::Station.create({:line => l, :type => "work"}) do |s|
              CloudFactory::InputHeader.new({:station => s, :label => "Company",:field_type => "text_data",:value => "Google", :required => true, :validation_format => "general"})
              CloudFactory::InputHeader.new({:station => s, :label => "Website",:field_type => "text_data",:value => "www.google.com", :required => true, :validation_format => "url"})
              CloudFactory::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CloudFactory::StandardInstruction.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
                CloudFactory::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
                CloudFactory::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
                CloudFactory::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})            
              end
            end
          end

          run = CloudFactory::Run.create(line, "run name", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))

          line.title.should eq("Digitize Card")

          line.stations.first.input_headers.first.label.should eq("Company")
          line.stations.first.input_headers.first.field_type.should eq("text_data")
          line.stations.first.input_headers.first.required.should eq(true)

          line.stations[0].type.should eq("Work") 

          line.stations[0].worker.number.should eq(1)
          line.stations[0].worker.reward.should eq(20)

          line.stations[0].instruction.title.should eq("Enter text from a business card image")
          line.stations[0].instruction.description.should eq("Describe")

          line.stations[0].instruction.form_fields[0].label.should eq("First Name")
          line.stations[0].instruction.form_fields[0].field_type.should eq("SA")
          line.stations[0].instruction.form_fields[0].required.should eq("true")

          run.title.should eq("run name")
          runfile = File.read(run.file)
          runfile.should == File.read(File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
        end
      end

      xit "for an existing line" do
        VCR.use_cassette "run/block/create-run-of-an-existing-line", :record => :new_episodes do
          line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
            CloudFactory::Station.create({:line => l, :type => "work"}) do |s|
              CloudFactory::InputHeader.new({:station => s, :label => "Company",:field_type => "text_data",:value => "Google", :required => true, :validation_format => "general"})
              CloudFactory::InputHeader.new({:station => s, :label => "Website",:field_type => "text_data",:value => "www.google.com", :required => true, :validation_format => "url"})
              CloudFactory::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CloudFactory::StandardInstruction.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
                CloudFactory::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
                CloudFactory::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
                CloudFactory::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})            
              end
            end
          end
          debugger
          old_line = CloudFactory::Line.find(line.id)
          run = CloudFactory::Run.create(old_line,"Run Using Line", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          run.title.should eq("Run Using Line")
        end
      end

      xit "for google_translator robot" do

      end

      it "for a line in a plain ruby way" do
        VCR.use_cassette "run/plain-ruby/create-run", :record => :new_episodes do
          line = CloudFactory::Line.new("Digitize Card", "Digitization")
          station = CloudFactory::Station.new({:type => "work"})
          line.stations station
          input_header_1 = CloudFactory::InputHeader.new({:label => "Company",:field_type => "text_data",:value => "Google", :required => true, :validation_format => "general"})
          input_header_2 = CloudFactory::InputHeader.new({:label => "Website",:field_type => "text_data",:value => "www.google.com", :required => true, :validation_format => "url"})
          line.stations.first.input_headers input_header_1
          line.stations.first.input_headers input_header_2
          worker = CloudFactory::HumanWorker.new({:number => 1, :reward => 20})
          line.stations.first.worker = worker

          form = CloudFactory::StandardInstruction.new({:title => "Enter text from a business card image", :description => "Describe"})
          line.stations.first.instruction = form

          form_fields_1 = CloudFactory::FormField.new({:label => "First Name", :field_type => "SA", :required => "true"})
          line.stations.first.instruction.form_fields form_fields_1
          form_fields_2 = CloudFactory::FormField.new({:label => "Middle Name", :field_type => "SA"})
          line.stations.first.instruction.form_fields form_fields_2
          form_fields_3 = CloudFactory::FormField.new({:label => "Last Name", :field_type => "SA", :required => "true"})
          line.stations.first.instruction.form_fields form_fields_3

          run = CloudFactory::Run.create(line,"Run in plain ruby way", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          
          line.title.should eq("Digitize Card")
          line.stations.first.type.should eq("WorkStation")

          line.stations.first.input_headers[0].label.should eq("Company")
          line.stations.first.input_headers[0].field_type.should eq("text_data")
          line.stations.first.input_headers[0].required.should eq("true")
          line.stations.first.input_headers[1].label.should eq("Website")
          line.stations.first.input_headers[1].field_type.should eq("text_data")
          line.stations.first.input_headers[1].required.should eq("true")

          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.reward.should eql(20)

          line.stations.first.instruction.title.should eql("Enter text from a business card image")
          line.stations.first.instruction.description.should eql("Describe")

          line.stations.first.instruction.form_fields[0].label.should eql("First Name")
          line.stations.first.instruction.form_fields[0].field_type.should eql("SA")
          line.stations.first.instruction.form_fields[0].required.should eql(true)
          line.stations.first.instruction.form_fields[1].label.should eql("Middle Name")
          line.stations.first.instruction.form_fields[1].field_type.should eql("SA")
          line.stations.first.instruction.form_fields[2].label.should eql("Last Name")
          line.stations.first.instruction.form_fields[2].field_type.should eql("SA")
          line.stations.first.instruction.form_fields[2].required.should eql(true)
        end
      end
    end
  end
end