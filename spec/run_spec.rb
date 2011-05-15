require 'spec_helper'

module CloudFactory
  describe CloudFactory::Run do
    context "create a new run" do
      xit "the plain ruby way" do
        VCR.use_cassette "run/create-run", :record => :new_episodes do
          worker = CloudFactory::HumanWorker.new(2, 0.2)

          form_fields = []
          form_fields << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
          form_fields << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
          form_fields << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")

          instruction =   CloudFactory::StandardInstruction.create(:title => "Title", :description => "Describe") do |i|
            i.form_fields = form_fields
          end
          line = CloudFactory::Line.create("Google Translator", "4dc8ad6572f8be0600000001") do |l|
            input_header1 = CloudFactory::InputHeader.new(l, {:label => "Name",:field_type => "text_data", :required => true})
            input_header2 = CloudFactory::InputHeader.new(l, {:label => "Age",:field_type => "text_data", :required => true})

            l.input_headers = [input_header1, input_header2]
            l.stations = CloudFactory::Station.create(l, :type => "Station 1 Name") do |station|
              station.worker = worker
              station.instruction = instruction
            end
          end
          run = CloudFactory::Run.create("run name") do |r|
            r.input_data [{:name => "Bob Smith", :age => 23}, {:name => "John Doe", :age => 24}]
          end
          line.name.should eq("Google Translator")
          line.input_headers.first.label.should eq("Name")
          line.input_headers.first.field_type.should eq("text_data")
          line.input_headers.first.required.should eq(true)
          line.stations.name.should eq("Station 1 Name") 
          line.stations.worker.should == worker
          line.stations.instruction.should == instruction
          run.name.should eq("run name")
          run.input_data.first[:name].should == "Bob Smith"
          run.input_data.first[:age].should == 23
        end
      end
    end
  end
end
