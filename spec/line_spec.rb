require 'spec_helper'

describe CloudFactory::Line do
  let(:input_header) { CloudFactory::InputHeader.new({:label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"}) }

  context "create a line" do
    it "the plain ruby way" do
      VCR.use_cassette "lines/create", :record => :new_episodes do
        line = CloudFactory::Line.new("Digitize Card", "Digitization")
        line.title.should eq("Digitize Card")
        line.category_name.should eq("Digitization")
      end
    end

    it "using block with variable" do
      VCR.use_cassette "lines/create-block-var", :record => :new_episodes do
        line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
          input_header = CloudFactory::InputHeader.new(l, {:label => "image_url",:field_type => "text_data",
            :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
            l.input_headers = [input_header]
          end
          line.title.should eq("Digitize Card")
          line.category_name.should eq("Digitization")
          line.input_headers.first.label.should == "image_url"
        end
      end
    end

    it "using block without variable" do
      VCR.use_cassette "lines/create-without-block-var", :record => :new_episodes do
        form_fields = []
        line = CloudFactory::Line.create("Digitize Card", "Digitization") do
          input_header = CloudFactory::InputHeader.new(self, {:label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
          input_headers [input_header]
          stations = CloudFactory::Station.create(self, :type => "work") do |station|
            worker = CloudFactory::HumanWorker.new(station, 2, 0.2)
            station.worker = worker
            station.instruction = CloudFactory::StandardInstruction.create(station,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
              form_fields << CloudFactory::FormField.new(station, {:label => "First Name", :field_type => "SA", :required => "true"})
              form_fields << CloudFactory::FormField.new(station, {:label => "Middle Name", :field_type => "SA"})
              form_fields << CloudFactory::FormField.new(station, {:label => "Last Name", :field_type => "SA", :required => "true"})
              i.form_fields = form_fields
            end
          end
        end
        line.title.should eq("Digitize Card")
        line.category_name.should eq("Digitization")
        line.input_headers.first.label.should == "image_url"
      end
    end

    it "with all the optional params" do
      VCR.use_cassette "lines/create-optional-params", :record => :new_episodes do 
        line = CloudFactory::Line.new("Line Name", "Digitization", {:public => true, :description => "this is description"})
        line.title.should eq("Line Name")
        line.category_name.should eq("Digitization")
        line.public.should == true
        line.description.should eq("this is description")
      end
    end

    context "with 1 station" do
      it "create with a new station" do
        VCR.use_cassette "lines/create-one-station", :record => :new_episodes do
          form_fields = []
          line_1 = CloudFactory::Line.create("Digitize Card", "Digitization") do |l|
            l.stations = CloudFactory::Station.create(l, :type => "work") do |station|
              worker = CloudFactory::HumanWorker.new(station, 2, 0.2)
              station.worker = worker
              station.instruction = CloudFactory::StandardInstruction.create(station,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
                form_fields << CloudFactory::FormField.new(station, {:label => "First Name", :field_type => "SA", :required => "true"})
                form_fields << CloudFactory::FormField.new(station, {:label => "Middle Name", :field_type => "SA"})
                form_fields << CloudFactory::FormField.new(station, {:label => "Last Name", :field_type => "SA", :required => "true"})
                i.form_fields = form_fields
              end
            end
          end
          line_1.title.should eq("Digitize Card")
          line_1.category_name.should eq("Digitization")
          line_1.stations.type.should eq("Work")
        end
      end
  end

  context "listing lines" do
    it "should list all the existing lines that belong to particular owner" do
      VCR.use_cassette "lines/listing-lines", :record => :new_episodes do
        5.times do |i|
          CloudFactory::Line.new("Digitize Card #{i}", "Digitization", {:public => false, :description => "#{i}-this is description"})
        end
        lines = CloudFactory::Line.my_lines
        lines.first.title.should eq("digitize-card-0")
        lines.size.should eql(5)
      end
    end

    it "should list all the public lines" do
      VCR.use_cassette "lines/listing-public-lines", :record => :new_episodes do
        5.times do |i|
          CloudFactory::Line.new("Digitize Card #{i}", "Digitization", {:public => false, :description => "#{i}-this is description"})
        end
        5.times do |i|
          CloudFactory::Line.new("Line #{i}", "Digitization", {:public => true, :description => "#{i}-this is description"})
        end
        lines = CloudFactory::Line.public_lines
        lines.first.title.should eq("line-0")
        lines.size.should eql(5) 
      end
    end
  end

  context "an existing line" do
    it "should get the line info" do
      VCR.use_cassette "lines/line-info", :record => :new_episodes do
        line = CloudFactory::Line.new("Digitize Card", "Digitization", {:public => true, :description => "this is description"})
        get_line = CloudFactory::Line.get_line(line)
        get_line.title.should eql("digitize-card")
        get_line.category_id.should eql("4db9319f703cf14825000001")
        get_line.public.should == true
        get_line.description.should eql("this is description")
      end
    end
  end

  context "Updating a line" do
    it "updates an existing line" do
      VCR.use_cassette "lines/update-line", :record => :new_episodes do
        line = CloudFactory::Line.new("Digitize Card", "Digitization", {:public => true, :description => "this is description"})
        line.update({:title => "New Title", :category_name => "Survey", :description => "this is new description"})
        updated_line = CloudFactory::Line.get_line(line)
        updated_line.title.should eql("new-title")
        updated_line.title.should_not eql("Digitize Card")
        updated_line.category_name.should eql("Survey")
        updated_line.category_name.should_not eql("Digitization")
        updated_line.description.should eql("this is new description")
        updated_line.description.should_not eql("this is description")
      end
    end
  end

  context "deleting" do
    it "should delete a line" do
      VCR.use_cassette "lines/delete-line", :record => :new_episodes do
        line = CloudFactory::Line.new("Digitize Card", "Digitization", {:public => true, :description => "this is description"})
        resp = line.delete
        begin
          CloudFactory::Line.get_line(line)
        rescue Exception => exec
          exec.class.should eql(Crack::ParseError)
        end
      end
    end
  end
  
  context "create a basic line" do
    it "should create a basic line with one station" do
      VCR.use_cassette "lines/create-basic-line", :record => :new_episodes do
        line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
          l.stations = CloudFactory::Station.create(l, :type => "work") do |s|
            s.worker = CloudFactory::HumanWorker.new(s, 2, 0.2)
            s.instruction = CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
              form_fields = []
              form_fields << CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
              form_fields << CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
              form_fields << CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})
              i.form_fields = form_fields
            end
          end
        end
        line.title.should eq("Digitize Card")
        line.stations.type.should eq("Work")
        line.stations.worker.number.should eq(2)
        line.stations.worker.reward.should eq(0.2)
        line.stations.instruction.title.should eq("Enter text from a business card image")
        line.stations.instruction.description.should eq("Describe")
        line.stations.instruction.form_fields[0].label.should eq("First Name")
        line.stations.instruction.form_fields[0].field_type.should eq("SA")
        line.stations.instruction.form_fields[0].required.should eq("true")
        line.stations.instruction.form_fields[1].label.should eq("Middle Name")
        line.stations.instruction.form_fields[1].field_type.should eq("SA")
        line.stations.instruction.form_fields[1].required.should eq(nil)
        line.stations.instruction.form_fields[2].label.should eq("Last Name")
        line.stations.instruction.form_fields[2].field_type.should eq("SA")
        line.stations.instruction.form_fields[2].required.should eq("true")
      end
    end
    
    it "should create a basic line with multiple station" do
      VCR.use_cassette "lines/create-basic-line-with-multiple-station", :record => :new_episodes do
        station = []
        line_1 = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
          station << CloudFactory::Station.create(l, :type => "work") do |s|
            s.worker = CloudFactory::HumanWorker.new(s, 2, 0.2)
            s.instruction = CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
              form_fields = []
              form_fields << CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
              form_fields << CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
              form_fields << CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})
              i.form_fields = form_fields
            end
          end
          
          station << CloudFactory::Station.create(l, :type => "Tournament") do |s|
            s.worker = CloudFactory::HumanWorker.new(s, 3, 0.3)
            s.instruction = CloudFactory::StandardInstruction.create(s,{:title => "Enter Name of Actor from the image", :description => "Enter name of an Actor"}) do |i|
              form_fields = []
              form_fields << CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
              form_fields << CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
              form_fields << CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})
              form_fields << CloudFactory::FormField.new(s, {:label => "Age", :field_type => "SA", :required => "true"})
              i.form_fields = form_fields
            end
          end
          
          l.stations = station
        end
        
        line = CloudFactory::Line.get_line(line_1)
        
        line.title.should eq("digitize-card")
        stations = CloudFactory::Station.all(line_1)
        stations[0]._type.should eq("WorkStation")
        #stations[0].worker.number.should eq(2)
        #stations[0].worker.reward.should eq(0.2)
        stations[0].instruction.title.should eq("Enter text from a business card image")
        stations[0].instruction.description.should eq("Describe")
        stations[0].instruction.form_fields[0].label.should eq("First Name")
        stations[0].instruction.form_fields[0].field_type.should eq("SA")
        stations[0].instruction.form_fields[0].required.should eq(true)
        stations[0].instruction.form_fields[1].label.should eq("Middle Name")
        stations[0].instruction.form_fields[1].field_type.should eq("SA")
        stations[0].instruction.form_fields[1].required.should eq(nil)
        stations[0].instruction.form_fields[2].label.should eq("Last Name")
        stations[0].instruction.form_fields[2].field_type.should eq("SA")
        stations[0].instruction.form_fields[2].required.should eq(true)
        
        stations[1]._type.should eq("TournamentStation")
        #stations[1].worker.number.should eq(3)
        #stations[1].worker.reward.should eq(0.3)
        stations[1].instruction.title.should eq("Enter Name of Actor from the image")
        stations[1].instruction.description.should eq("Enter name of an Actor")
        stations[1].instruction.form_fields[0].label.should eq("First Name")
        stations[1].instruction.form_fields[0].field_type.should eq("SA")
        stations[1].instruction.form_fields[0].required.should eq(true)
        stations[1].instruction.form_fields[1].label.should eq("Middle Name")
        stations[1].instruction.form_fields[1].field_type.should eq("SA")
        stations[1].instruction.form_fields[1].required.should eq(nil)
        stations[1].instruction.form_fields[2].label.should eq("Last Name")
        stations[1].instruction.form_fields[2].field_type.should eq("SA")
        stations[1].instruction.form_fields[2].required.should eq(true)
        stations[1].instruction.form_fields[3].label.should eq("Age")
        stations[1].instruction.form_fields[3].field_type.should eq("SA")
        stations[1].instruction.form_fields[3].required.should eq(true)
        
      end
    end
  end
end