require 'spec_helper'

module CloudFactory
  describe CloudFactory::Run do
    context "create a new run" do
      it "the plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "run/create-run", :record => :new_episodes do

          attrs_1 = {:label => "Company",
            :field_type => "text_data",
            :value => "Apple", 
            :required => true, 
            :validation_format => "general"
          }

          attrs_2 = {:label => "Website",
            :field_type => "text_data",
            :value => "apple.com", 
            :required => true, 
            :validation_format => "url"
          }

          line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
            CloudFactory::InputHeader.new(l, attrs_1)
            CloudFactory::InputHeader.new(l, attrs_2) 
            CloudFactory::Station.create(l, :type => "work") do |s|
              CloudFactory::HumanWorker.new(s, 2, 0.2)
              CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
                CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
                CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
                CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})            
              end
            end
          end

          run = CloudFactory::Run.create(line, "run name", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))

          line.title.should eq("Digitize Card")

          line.input_headers.first.label.should eq("Company")
          line.input_headers.first.field_type.should eq("text_data")
          line.input_headers.first.required.should eq(true)

          line.stations[0].type.should eq("Work") 

          line.stations[0].worker.number.should eq(2)
          line.stations[0].worker.reward.should eq(0.2)

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

      it "should create a run for an existing line" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "run/create-run-of-an-existing-line", :record => :new_episodes do
          attrs_1 = {:label => "Company",
            :field_type => "text_data",
            :value => "Apple", 
            :required => true, 
            :validation_format => "general"
          }

          attrs_2 = {:label => "Website",
            :field_type => "text_data",
            :value => "apple.com", 
            :required => true, 
            :validation_format => "url"
          }

          line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
            CloudFactory::InputHeader.new(l, attrs_1)
            CloudFactory::InputHeader.new(l, attrs_2) 
            CloudFactory::Station.create(l, :type => "work") do |s|
              CloudFactory::HumanWorker.new(s, 2, 0.2)
              CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
                CloudFactory::FormField.new(s, {:label => "Company Name", :field_type => "SA", :required => "true"})
                CloudFactory::FormField.new(s, {:label => "Website URL", :field_type => "SA", :required => "true"})
              end
            end
          end

          old_line = CloudFactory::Line.find(line.id)
          run = CloudFactory::Run.create(old_line,"Run Using Line", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          run.title.should eq("Run Using Line")
        end
      end
    
      xit "should create a run for google_translator robot" do
        
      end
    end
  end
end
