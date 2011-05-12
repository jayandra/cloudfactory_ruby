require 'spec_helper'

describe CloudFactory::Line do
  let(:input_header) { CloudFactory::InputHeader.new({:label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"}) }
  
  context "create a line" do
    
    # use_vcr_cassette "lines/create", :record => :new_episodes
    
    it "the plain ruby way", :focus => true do
      VCR.use_cassette "lines/create", :record => :new_episodes do
        line = CloudFactory::Line.new("Digitize Card","4dc8ad6572f8be0600000001")
        line.title.should eq("Digitize Card")
        line.category_id.should eq("4dc8ad6572f8be0600000001")
      end
    end
    
    it "using block with variable", :focus => true do
      VCR.use_cassette "lines/create-block-var", :record => :new_episodes do
      
      line = CloudFactory::Line.create("Digitize Card","4dc8ad6572f8be0600000001") do |l|
        input_header = CloudFactory::InputHeader.new({:label => "image_url",:field_type => "text_data",
            :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
        l.input_headers = [input_header]
      end
      line.title.should eq("Digitize Card")
      line.category_id.should eq("4dc8ad6572f8be0600000001")
      line.input_headers.first.label.should == "image_url"
    end
    end

    it "using block without variable", :focus => true do
      VCR.use_cassette "lines/create-without-block-var", :record => :new_episodes do
      input_header = CloudFactory::InputHeader.new({:label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
      worker = CloudFactory::HumanWorker.new(2, 0.2)
      form_fields = []
      form_fields << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
      form_fields << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
      form_fields << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")
      line = CloudFactory::Line.create("Digitize Card", "4dc8ad6572f8be0600000001") do
        input_headers [input_header]
        stations = CloudFactory::Station.create(self, :type => "work") do |station|
          station.worker = worker
          station.instruction = CloudFactory::StandardInstruction.create(:title => "Enter text from a business card image", :description => "Describe") do |i|
            i.form_fields = form_fields
          end
        end
      end
      line.title.should eq("Digitize Card")
      line.category_id.should eq("4dc8ad6572f8be0600000001")
      line.input_headers.first.label.should == "image_url"
    end
    end
    
    it "with all the optional params", :focus => true do
      VCR.use_cassette "lines/create-optional-params", :record => :new_episodes do
      # title, category along with optional description, public
      line = CloudFactory::Line.new("Line Name", "4dc8ad6572f8be0600000001", {:public => true, :description => "this is description"})
      line.title.should eq("Line Name")
      line.category_id.should eq("4dc8ad6572f8be0600000001")
      line.public.should == true
      line.description.should eq("this is description")
    end
    end
    
    context "with 1 station" do
      it "create with a new station" do
        worker = CloudFactory::HumanWorker.new(2, 0.2)
        form_fields = []
        form_fields << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
        form_fields << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
        form_fields << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")
        
        line_1 = CloudFactory::Line.create("Digitize Card", "4dc8ad6572f8be0600000001") do |l|
          l.stations = CloudFactory::Station.create(l, :type => "work") do |station|
            station.worker = worker
            station.instruction = CloudFactory::StandardInstruction.create(:title => "Enter text from a business card image", :description => "Describe") do |i|
              i.form_fields = form_fields
            end
          end
        end
        line_1.title.should eq("Digitize Card")
        line_1.category_id.should eq("4dc8ad6572f8be0600000001")
        line_1.stations.type.should eq("Work")
        line_1.stations.worker.should == worker
      end
    end
    
  end
  
  context "listing lines" do
    it "should list all the existing lines that belong to particular owner" do
      
      5.times do |i|
        CloudFactory::Line.new("Digitize Card #{i}", "4dc8ad6572f8be0600000001", {:public => false, :description => "#{i}-this is description"})
      end
      
      lines = CloudFactory::Line.my_lines
      lines.first.title.should eq("digitize-card-0")
      lines.size.should eql(5)
    end
    
    it "should list all the public lines" do
      lines = CloudFactory::Line.public_lines
      lines.first.title.should eq("test-another") 
    end
  end
  
  context "an existing line" do
    it "should get the line info" do
     line = CloudFactory::Line.new("Digitize Card", "4dc8ad6572f8be0600000001", {:public => true, :description => "this is description"})
     get_line = CloudFactory::Line.get_line(line).title.should eql("digitize-card")
     get_line.get_line(line).category_id.should eql("4dc8ad6572f8be0600000001")
     get_line.get_line(line).public.should == true
     get_line.get_line(line).description.should eql("this is description")
    end
  end
  
  context "Updating a line" do
    it "updates an existing line" do
     line = CloudFactory::Line.new("Digitize Card", "4dc8ad6572f8be0600000001", {:public => true, :description => "this is description"})
     line.update({:title => "New Title", :category_id => "4dc8ad6572f8be0600000001", :description => "this is new description"})
     updated_line = CloudFactory::Line.get_line(line).title.should eql("new-title")
     updated_line.title.should_not eql("Digitize Card")
     updated_line.description.should eql("this is new description")
     updated_line.description.should_not eql("this is description")
    end
  end
  
  context "deleting" do
    it "should delete a line" do
      line = CloudFactory::Line.new("Digitize Card", "4dc8ad6572f8be0600000001", {:public => true, :description => "this is description"})
      line.delete
      begin
        CloudFactory::Line.get_line(line)
      rescue Exception => exec
        exec.class.should eql(Crack::ParseError)
      end
    end
  end
end
