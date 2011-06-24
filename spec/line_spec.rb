require 'spec_helper'

describe CF::Line do
  let(:input_format) { CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"}) }

  context "create a line" do
    it "the plain ruby way" do
      VCR.use_cassette "lines/block/create", :record => :new_episodes do
        line = CF::Line.new("Digitize Card", "Digitization")
        line.title.should eq("Digitize Card")
        line.department_name.should eq("Digitization")
      end
    end

    it "using block with variable" do
      VCR.use_cassette "lines/block/create-block-var", :record => :new_episodes do
        line = CF::Line.create("Digitize Card","Digitization") do |l|
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::InputFormat.new({:station => s, :name => "image_url", :required => true, :valid_type => "url"})
            CF::InputFormat.new({:station => s, :name => "image", :required => true, :valid_type => "url"})
          end
        end
        line.title.should eq("Digitize Card")
        line.department_name.should eq("Digitization")
        line.stations.first.input_formats[0].name.should eql("image_url")
        line.stations.first.input_formats[1].name.should eql("image")
        line.stations.first.type.should eq("Work")
      end
    end

    it "using block without variable" do
      VCR.use_cassette "lines/block/create-without-block-var", :record => :new_episodes do
        line = CF::Line.create("Digitize Card", "Digitization") do
          CF::Station.create({:line => self, :type => "work"}) do |station|
            CF::InputFormat.new({:station => station, :name => "image_url", :required => true, :valid_type => "url"})
            CF::HumanWorker.new({:station => station, :number => 2, :reward => 20})
            CF::TaskForm.create({:station => station, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
              CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.title.should eq("Digitize Card")
        line.department_name.should eq("Digitization")
        line.stations.first.input_formats.first.name.should eql("image_url")
        line.stations.first.type.should eq("Work")
        line.stations.first.worker.number.should eq(2)
        line.stations.first.form.instruction.should eq("Describe")
        line.stations.first.form.form_fields.first.label.should eq("First Name")
      end
    end

    it "with all the optional params" do
      VCR.use_cassette "lines/block/create-optional-params", :record => :new_episodes do
        line = CF::Line.new("Line Name", "Digitization", {:public => true, :description => "this is description"})
        line.title.should eq("Line Name")
        line.department_name.should eq("Digitization")
        line.public.should eql(true)
        line.description.should eq("this is description")
      end
    end
  end

  context "with 1 station" do
    it "create with a new station" do
      VCR.use_cassette "lines/block/create-one-station", :record => :new_episodes do
        line = CF::Line.create("Digitize Card", "Digitization") do |l|
          CF::Station.create({:line => l, :type => "work"}) do |station|
            CF::HumanWorker.new({:line => l, :station => station, :number => 2, :reward => 20})
            CF::TaskForm.create({:station => station, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
              CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.title.should eq("Digitize Card")
        line.department_name.should eq("Digitization")
        line.stations.first.type.should eq("Work")
        line.stations.first.worker.number.should eq(2)
        line.stations.first.worker.reward.should eq(20)
        line.stations.first.form.title.should eq("Enter text from a business card image")
        line.stations.first.form.instruction.should eq("Describe")
        line.stations.first.form.form_fields.first.label.should eq("First Name")
        line.stations.first.form.form_fields.first.field_type.should eq("SA")
        line.stations.first.form.form_fields.first.required.should eq("true")
      end
    end
  end

  context "listing lines" do
    it "should list all the existing lines that belong to particular owner" do
      VCR.use_cassette "lines/block/listing-lines", :record => :new_episodes do
        5.times do |i|
          CF::Line.new("Digitize Card #{i}", "Digitization", {:public => false, :description => "#{i}-this is description"})
        end
        lines = CF::Line.all
        lines.last.title.should eq("digitize-card-0")
        lines.size.should eql(5)
      end
    end

    it "should list all the public lines" do
      VCR.use_cassette "lines/block/listing-public-lines", :record => :new_episodes do
        1.times do |i|
          CF::Line.new("Digitize Card #{i}", "Digitization", {:public => false, :description => "#{i}-this is description"})
        end
        2.times do |i|
          CF::Line.new("Line #{i}", "Digitization", {:public => true, :description => "#{i}-this is description"})
        end

        lines = CF::Line.public_lines
        lines.first.title.should eq("line-1")
        lines.size.should eql(2)
      end
    end
  end

  context "an existing line" do
    it "should get the line info" do
      VCR.use_cassette "lines/block/line-info", :record => :new_episodes do
        line = CF::Line.new("Digitize Card", "Digitization", {:public => true, :description => "this is description"})
        get_line = CF::Line.info(line)
        get_line.title.should eql("digitize-card")
        get_line.id.should eql(line.id)
        get_line.public.should eql(true)
        get_line.description.should eql("this is description")
      end
    end
  end

  context "Updating a line" do
    it "updates an existing line" do
      VCR.use_cassette "lines/block/update-line", :record => :new_episodes do
        line = CF::Line.new("Digitize Card", "Digitization", {:public => true, :description => "this is description"})
        line.update({:title => "New Title", :department_name => "Survey", :description => "this is new description"})
        updated_line = CF::Line.info(line)
        updated_line.title.should eql("new-title")
        updated_line.title.should_not eql("Digitize Card")
        updated_line.department_name.should eql("Survey")
        updated_line.department_name.should_not eql("Digitization")
        updated_line.description.should eql("this is new description")
        updated_line.description.should_not eql("this is description")
      end
    end
  end

  context "deleting" do
    it "should delete a line" do
      VCR.use_cassette "lines/block/delete-line", :record => :new_episodes do
        line = CF::Line.new("Digitize Card", "Digitization", {:public => true, :description => "this is description"})
        resp = line.delete
        resp.code.should eql(200)
        deleted_resp = CF::Line.info(line)
        deleted_resp.message.should eql("Resource not found.")
      end
    end
  end

  context "create a basic line" do
    it "should create a basic line with one station" do
      VCR.use_cassette "lines/block/create-basic-line", :record => :new_episodes do
        line = CF::Line.create("Digitize Card","Digitization") do |l|
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::HumanWorker.new({:station => s, :number => 2, :reward => 20})
            CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
              CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.title.should eq("Digitize Card")
        line.stations.first.type.should eq("Work")
        line.stations.first.worker.number.should eq(2)
        line.stations.first.worker.reward.should eq(20)
        line.stations.first.form.title.should eq("Enter text from a business card image")
        line.stations.first.form.instruction.should eq("Describe")
        line.stations.first.form.form_fields[0].label.should eq("First Name")
        line.stations.first.form.form_fields[0].field_type.should eq("SA")
        line.stations.first.form.form_fields[0].required.should eq("true")
        line.stations.first.form.form_fields[1].label.should eq("Middle Name")
        line.stations.first.form.form_fields[1].field_type.should eq("SA")
        line.stations.first.form.form_fields[1].required.should eq(nil)
        line.stations.first.form.form_fields[2].label.should eq("Last Name")
        line.stations.first.form.form_fields[2].field_type.should eq("SA")
        line.stations.first.form.form_fields[2].required.should eq("true")
      end
    end
  end

  context "create line using plain ruby way" do
    it "should create a station " do
      VCR.use_cassette "lines/plain-ruby/create-station", :record => :new_episodes do
        line = CF::Line.new("Digitize Card", "Digitization")
        station = CF::Station.new({:type => "work"})
        line.stations station
        line.stations.first.type.should eql("Work")
      end
    end

    it "should create a human worker within station" do
      VCR.use_cassette "lines/plain-ruby/create-station", :record => :new_episodes do
        line = CF::Line.new("Digitize Card", "Digitization")
        station = CF::Station.new({:type => "work"})
        line.stations station
        worker = CF::HumanWorker.new({:number => 2, :reward => 20})
        line.stations.first.worker = worker
        line.stations.first.type.should eql("Work")
        line.stations.first.worker.number.should eql(2)
        line.stations.first.worker.reward.should eql(20)
      end
    end

    it "should create a StandardInstruciton within station" do
      VCR.use_cassette "lines/plain-ruby/create-form", :record => :new_episodes do
        line = CF::Line.new("Digitize Card", "Digitization")
        station = CF::Station.new({:type => "work"})
        line.stations station

        worker = CF::HumanWorker.new({:number => 2, :reward => 20})
        line.stations.first.worker = worker

        form = CF::TaskForm.new({:title => "Enter text from a business card image", :instruction => "Describe"})
        line.stations.first.form = form
        line.stations.first.form.title.should eql("Enter text from a business card image")
        line.stations.first.form.instruction.should eql("Describe")
      end
    end

    it "should create an input header within line" do
      VCR.use_cassette "lines/plain-ruby/create-input-header", :record => :new_episodes do
        line = CF::Line.new("Digitize Card", "Digitization")
        station = CF::Station.new({:type => "work"})
        line.stations station
        input_format = CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"})
        line.stations.first.input_formats input_format
        line.stations.first.input_formats.first.name.should eq("image_url")
        line.stations.first.input_formats.first.required.should eq(true)
        line.stations.first.input_formats.first.valid_type.should eq("url")
      end
    end

    it "should create form fields within the standard instruction" do
      VCR.use_cassette "lines/plain-ruby/create-form-fields", :record => :new_episodes do
        line = CF::Line.new("Digitize Card", "Digitization")
        station = CF::Station.new({:type => "work"})
        line.stations station

        worker = CF::HumanWorker.new({:number => 2, :reward => 20})
        line.stations.first.worker = worker

        form = CF::TaskForm.new({:title => "Enter text from a business card image", :instruction => "Describe"})
        line.stations.first.form = form

        form_fields_1 = CF::FormField.new({:label => "First Name", :field_type => "SA", :required => "true"})
        line.stations.first.form.form_fields form_fields_1
        form_fields_2 = CF::FormField.new({:label => "Middle Name", :field_type => "SA"})
        line.stations.first.form.form_fields form_fields_2
        form_fields_3 = CF::FormField.new({:label => "Last Name", :field_type => "SA", :required => "true"})
        line.stations.first.form.form_fields form_fields_3

        line.stations.first.form.form_fields[0].label.should eql("First Name")
        line.stations.first.form.form_fields[0].field_type.should eq("SA")
        line.stations.first.form.form_fields[0].required.should eq(true)
        line.stations.first.form.form_fields[1].label.should eql("Middle Name")
        line.stations.first.form.form_fields[1].field_type.should eq("SA")
        line.stations.first.form.form_fields[2].label.should eql("Last Name")
        line.stations.first.form.form_fields[2].field_type.should eq("SA")
        line.stations.first.form.form_fields[2].required.should eq(true)
      end
    end
  end
end