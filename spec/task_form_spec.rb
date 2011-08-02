require 'spec_helper'

describe CF::TaskForm do
  context "create a task_form" do
    it "the plain ruby way" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "task_form/block/create", :record => :new_episodes do
        line = CF::Line.create("Digiti-ard-2", "Digitization") do
          CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line => self, :type => "work"}) do |station|
            CF::HumanWorker.new({:station => station, :number => 2, :reward => 20})
            CF::TaskForm.create({:station => station, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
              CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        form = line.stations[0].form
        form.title.should eq("Enter text from a business card image")
        form.instruction.should eq("Describe")
        form.form_fields.first.label.should eq("First Name")
        form.form_fields.first.field_type.should eq("SA")
        form.form_fields.first.required.should eq(true)
      end
    end

    xit "with invalid data" do
      WebMock.allow_net_connect!
      # VCR.use_cassette "task_form/block/create", :record => :new_episodes do
      line = CF::Line.create("Digiti-ard-2", "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => self, :type => "work"}) do |station|
          CF::HumanWorker.new({:station => station, :number => 2, :reward => 20})
          CF::TaskForm.new({:station => station})
        end
      end
      # debugger
      form = line.stations[0].form
      form.instruction.should eq("Describe")
      form.form_fields.first.label.should eq("First Name")
      form.form_fields.first.field_type.should eq("SA")
      form.form_fields.first.required.should eq(true)
      # end
    end
  end

  context "get instruction info" do
    it "should get all the instruction information of a station" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "task_form/block/get-instruction", :record => :new_episodes do
        line = CF::Line.create("Digitizerdd", "Digitization") do
          CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line => self, :type => "work"}) do |station|
            CF::HumanWorker.new({:station => station, :number => 2, :reward => 20})
            CF::TaskForm.create({:station => station, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
              CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        @got_instruction = line.stations.first.get_form
        @got_instruction.title.should eq("Enter text from a business card image")
        @got_instruction.instruction.should eq("Describe")
      end
    end
  end

  context "Delete instruction" do
    it "should delete instruction of a station" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "task_form/block/delete-instruction", :record => :new_episodes do
        line = CF::Line.create("Digitize-d111", "Digitization") do
          CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line => self, :type => "work"}) do |station|
            CF::HumanWorker.new({:station => station, :number => 2, :reward => 20})
            CF::TaskForm.create({:station => station, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
              CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        @got_instruction = line.stations.first.get_form
        @got_instruction.title.should eq("Enter text from a business card image")
        @got_instruction.instruction.should eq("Describe")

        station = line.stations[0]
        deleted_response = CF::TaskForm.delete_instruction(station)

        deleted_response.code.should eq(200)
      end
    end
  end
end