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
          CloudFactory::InputHeader.new(l, {:label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
          CloudFactory::InputHeader.new(l, {:label => "image",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})  
          CloudFactory::Station.new(l, :type => "work")
        end
        line.title.should eq("Digitize Card")
        line.category_name.should eq("Digitization")
        line.input_headers[0].label.should == "image_url"
        line.input_headers[1].label.should == "image"
        line.stations.first.type.should eq("Work")
      end
    end

    it "using block without variable" do
      VCR.use_cassette "lines/create-without-block-var", :record => :new_episodes do
        line = CloudFactory::Line.create("Digitize Card", "Digitization") do
          CloudFactory::InputHeader.new(self, {:label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
          CloudFactory::Station.create(self,{:type => "work"}) do |station|
            CloudFactory::HumanWorker.new(station, 2, 0.2)
            CloudFactory::StandardInstruction.create(station,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
              CloudFactory::FormField.new(station, {:label => "First Name", :field_type => "SA", :required => "true"})
              CloudFactory::FormField.new(station, {:label => "Middle Name", :field_type => "SA"})
              CloudFactory::FormField.new(station, {:label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.title.should eq("Digitize Card")
        line.category_name.should eq("Digitization")
        line.input_headers.first.label.should == "image_url"
        line.stations.first.type.should eq("Work")
        line.stations.first.worker.number.should eq(2)
        line.stations.first.instruction.description.should eq("Describe")
        line.stations.first.instruction.form_fields.first.label.should eq("First Name")
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
  end
  
  context "with 1 station" do
    it "create with a new station" do
      VCR.use_cassette "lines/create-one-station", :record => :new_episodes do
        line = CloudFactory::Line.create("Digitize Card", "Digitization") do |l|
          CloudFactory::Station.create(l, :type => "work") do |station|
            CloudFactory::HumanWorker.new(station, 2, 0.2)
            CloudFactory::StandardInstruction.create(station,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
              CloudFactory::FormField.new(station, {:label => "First Name", :field_type => "SA", :required => "true"})
              CloudFactory::FormField.new(station, {:label => "Middle Name", :field_type => "SA"})
              CloudFactory::FormField.new(station, {:label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.title.should eq("Digitize Card")
        line.category_name.should eq("Digitization")
        line.stations.first.type.should eq("Work")
        line.stations.first.worker.number.should eq(2)
        line.stations.first.worker.reward.should eq(0.2)
        line.stations.first.instruction.title.should eq("Enter text from a business card image")
        line.stations.first.instruction.description.should eq("Describe")
        line.stations.first.instruction.form_fields.first.label.should eq("First Name")
        line.stations.first.instruction.form_fields.first.field_type.should eq("SA")
        line.stations.first.instruction.form_fields.first.required.should eq("true")
      end
    end
  end

  context "listing lines" do
    it "should list all the existing lines that belong to particular owner" do
      VCR.use_cassette "lines/listing-lines", :record => :new_episodes do
        5.times do |i|
          CloudFactory::Line.new("Digitize Card #{i}", "Digitization", {:public => false, :description => "#{i}-this is description"})
        end
        lines = CloudFactory::Line.all
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
        lines = CloudFactory::Line.public
        lines.first.title.should eq("line-0")
        lines.size.should eql(5) 
      end
    end
  end

  context "an existing line" do
    it "should get the line info" do
      VCR.use_cassette "lines/line-info", :record => :new_episodes do
        line = CloudFactory::Line.new("Digitize Card", "Digitization", {:public => true, :description => "this is description"})
        get_line = CloudFactory::Line.info(line)
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
        updated_line = CloudFactory::Line.info(line)
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
          CloudFactory::Line.info(line)
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
          CloudFactory::Station.create(l, :type => "work") do |s|
            CloudFactory::HumanWorker.new(s, 2, 0.2)
            CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
              CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
              CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
              CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})            
            end
          end
        end
        line.title.should eq("Digitize Card")
        line.stations.first.type.should eq("Work")
        line.stations.first.worker.number.should eq(2)
        line.stations.first.worker.reward.should eq(0.2)
        line.stations.first.instruction.title.should eq("Enter text from a business card image")
        line.stations.first.instruction.description.should eq("Describe")
        line.stations.first.instruction.form_fields[0].label.should eq("First Name")
        line.stations.first.instruction.form_fields[0].field_type.should eq("SA")
        line.stations.first.instruction.form_fields[0].required.should eq("true")
        line.stations.first.instruction.form_fields[1].label.should eq("Middle Name")
        line.stations.first.instruction.form_fields[1].field_type.should eq("SA")
        line.stations.first.instruction.form_fields[1].required.should eq(nil)
        line.stations.first.instruction.form_fields[2].label.should eq("Last Name")
        line.stations.first.instruction.form_fields[2].field_type.should eq("SA")
        line.stations.first.instruction.form_fields[2].required.should eq("true")
      end
    end

    it "should create a basic line with multiple station" do
      VCR.use_cassette "lines/create-basic-line-with-multiple-station", :record => :new_episodes do
        line_1 = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
          CloudFactory::Station.create(l, :type => "work") do |s|
            CloudFactory::HumanWorker.new(s, 2, 0.2)
            CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
              CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
              CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
              CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end

          CloudFactory::Station.create(l, :type => "Tournament") do |s|
            CloudFactory::HumanWorker.new(s, 3, 0.3)
            CloudFactory::StandardInstruction.create(s,{:title => "Enter Name of Actor from the image", :description => "Enter name of an Actor"}) do |i|
              CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
              CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
              CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})
              CloudFactory::FormField.new(s, {:label => "Age", :field_type => "SA", :required => "true"})
            end
          end
        end 

        line = CloudFactory::Line.info(line_1)

        line.title.should eq("digitize-card")
        stations = CloudFactory::Station.all(line_1)
        stations[0]._type.should eq("WorkStation")
        #stations[0].worker.number.should eq(2)
        #stations[0].worker.reward.should eq(0.2)
        instruction_1 = line_1.stations[0].get_instruction
        instruction_1.title.should eq("Enter text from a business card image")
        instruction_1.description.should eq("Describe")
        instruction_1.form_fields[0].label.should eq("First Name")
        instruction_1.form_fields[0].field_type.should eq("SA")
        instruction_1.form_fields[0].required.should eq(true)
        instruction_1.form_fields[1].label.should eq("Middle Name")
        instruction_1.form_fields[1].field_type.should eq("SA")
        instruction_1.form_fields[1].required.should eq(nil)
        instruction_1.form_fields[2].label.should eq("Last Name")
        instruction_1.form_fields[2].field_type.should eq("SA")
        instruction_1.form_fields[2].required.should eq(true)

        stations[3]._type.should eq("TournamentStation")
        #stations[1].worker.number.should eq(3)
        #stations[1].worker.reward.should eq(0.3)
        instruction_2 = line_1.stations[1].get_instruction
        instruction_2.title.should eq("Enter Name of Actor from the image")
        instruction_2.description.should eq("Enter name of an Actor")
        instruction_2.form_fields[0].label.should eq("First Name")
        instruction_2.form_fields[0].field_type.should eq("SA")
        instruction_2.form_fields[0].required.should eq(true)
        instruction_2.form_fields[1].label.should eq("Middle Name")
        instruction_2.form_fields[1].field_type.should eq("SA")
        instruction_2.form_fields[1].required.should eq(nil)
        instruction_2.form_fields[2].label.should eq("Last Name")
        instruction_2.form_fields[2].field_type.should eq("SA")
        instruction_2.form_fields[2].required.should eq(true)
        instruction_2.form_fields[3].label.should eq("Age")
        instruction_2.form_fields[3].field_type.should eq("SA")
        instruction_2.form_fields[3].required.should eq(true)

      end
    end
  end
end