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

end