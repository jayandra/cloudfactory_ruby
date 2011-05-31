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
        line.input_headers[0].label.should eql("image_url")
        line.input_headers[1].label.should eql("image")
        line.stations.first.type.should eq("Work")
      end
    end

    it "using block without variable" do
      VCR.use_cassette "lines/create-without-block-var", :record => :new_episodes do
        line = CloudFactory::Line.create("Digitize Card", "Digitization") do
          CloudFactory::InputHeader.new(self, {:label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
          CloudFactory::Station.create(self,{:type => "work"}) do |station|
            CloudFactory::HumanWorker.new(station, 2, 20)
            CloudFactory::StandardInstruction.create(station,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
              CloudFactory::FormField.new(i, {:label => "First Name", :field_type => "SA", :required => "true"})
              CloudFactory::FormField.new(i, {:label => "Middle Name", :field_type => "SA"})
              CloudFactory::FormField.new(i, {:label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.title.should eq("Digitize Card")
        line.category_name.should eq("Digitization")
        line.input_headers.first.label.should eql("image_url")
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
        line.public.should eql(true)
        line.description.should eq("this is description")
      end
    end
  end

  context "with 1 station" do
    it "create with a new station" do
      VCR.use_cassette "lines/create-one-station", :record => :new_episodes do
        line = CloudFactory::Line.create("Digitize Card", "Digitization") do |l|
          CloudFactory::Station.create(l, :type => "work") do |station|
            CloudFactory::HumanWorker.new(station, 2, 20)
            CloudFactory::StandardInstruction.create(station,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
              CloudFactory::FormField.new(i, {:label => "First Name", :field_type => "SA", :required => "true"})
              CloudFactory::FormField.new(i, {:label => "Middle Name", :field_type => "SA"})
              CloudFactory::FormField.new(i, {:label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.title.should eq("Digitize Card")
        line.category_name.should eq("Digitization")
        line.stations.first.type.should eq("Work")
        line.stations.first.worker.number.should eq(2)
        line.stations.first.worker.reward.should eq(20)
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
        1.times do |i|
          CloudFactory::Line.new("Digitize Card #{i}", "Digitization", {:public => false, :description => "#{i}-this is description"})
        end
        2.times do |i|
          CloudFactory::Line.new("Line #{i}", "Digitization", {:public => true, :description => "#{i}-this is description"})
        end
        
        lines = CloudFactory::Line.public_lines
        lines.first.title.should eq("line-0")
        lines.size.should eql(2) 
      end
    end
  end

  context "an existing line" do
    it "should get the line info" do
      VCR.use_cassette "lines/line-info", :record => :new_episodes do
        line = CloudFactory::Line.new("Digitize Card", "Digitization", {:public => true, :description => "this is description"})
        get_line = CloudFactory::Line.info(line)
        get_line.title.should eql("digitize-card")
        get_line._id.should eql(line.id)
        get_line.public.should eql(true)
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
        resp.code.should eql(200)
        deleted_resp = CloudFactory::Line.info(line)
        deleted_resp.message.should eql("Resource not found.")
        deleted_resp.code.should eql(404)
      end
    end
  end

  context "create a basic line" do
    it "should create a basic line with one station" do
      VCR.use_cassette "lines/create-basic-line", :record => :new_episodes do
        line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
          CloudFactory::Station.create(l, :type => "work") do |s|
            CloudFactory::HumanWorker.new(s, 2, 20)
            CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
              CloudFactory::FormField.new(i, {:label => "First Name", :field_type => "SA", :required => "true"})
              CloudFactory::FormField.new(i, {:label => "Middle Name", :field_type => "SA"})
              CloudFactory::FormField.new(i, {:label => "Last Name", :field_type => "SA", :required => "true"})            
            end
          end
        end
        line.title.should eq("Digitize Card")
        line.stations.first.type.should eq("Work")
        line.stations.first.worker.number.should eq(2)
        line.stations.first.worker.reward.should eq(20)
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
  end
end