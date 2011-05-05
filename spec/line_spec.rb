require 'spec_helper'

describe CloudFactory::Line do
  let(:input_header) { CloudFactory::InputHeader.new({:label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"}) }
  
  context "create a line" do
    it "the plain ruby way" do
      line = CloudFactory::Line.new("Digitize Card")
      line.name.should eq("Digitize Card")
    end
    
    it "using block with variable" do
      input_header = CloudFactory::InputHeader.new({:label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
      line = CloudFactory::Line.create("Digitize Card") do |l|
        input_header = CloudFactory::InputHeader.new({:label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
        l.input_headers = [input_header]
      end
      line.name.should eq("Digitize Card")
      line.input_headers.first.label.should == "image_url"
    end

    it "using block without variable" do
      input_header = CloudFactory::InputHeader.new({:label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
      line = CloudFactory::Line.create("Digitize Card") do
        input_headers [input_header]
      end
      line.name.should eq("Digitize Card")
      line.input_headers.first.label.should == "image_url"
    end
    
    context "with 1 station" do
      it "create with a new station" do
        worker = CloudFactory::HumanWorker.new(2, 0.2)
        form_fields = []
        form_fields << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
        form_fields << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
        form_fields << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")
        
        line_1 = CloudFactory::Line.create("Digitize Card") do |l|
          l.stations = CloudFactory::Station.create("Station 1 Name") do |station|
            station.worker = worker
            station.instruction = CloudFactory::StandardInstruction.create(:title => "Enter text from a business card image", :description => "Describe") do |i|
              i.form_fields = form_fields
            end
          end
        end
        line_1.name.should eq("Digitize Card")
        line_1.stations.name.should eq("Station 1 Name")
        line_1.stations.worker.should == worker
      end
      
    end
  end
  
end
