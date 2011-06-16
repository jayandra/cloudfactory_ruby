require 'spec_helper'

describe CF::FormField do
  context "create an form_field" do
    it "the plain ruby way" do
      VCR.use_cassette "form-fields/plain-ruby/create-form-fields", :record => :new_episodes do
        line = CF::Line.new("Digitize Card", "Digitization")
        station = CF::Station.new({:type => "work"})
        line.stations station

        worker = CF::HumanWorker.new({:number => 2, :reward => 20})
        line.stations.first.worker = worker

        form = CF::TaskForm.new({:title => "Enter text from a business card image", :description => "Describe"})
        line.stations.first.instruction = form

        form_fields_1 = CF::FormField.new({:label => "First Name", :field_type => "SA", :required => "true"})
        line.stations.first.instruction.form_fields form_fields_1
        form_fields_2 = CF::FormField.new({:label => "Middle Name", :field_type => "SA"})
        line.stations.first.instruction.form_fields form_fields_2
        form_fields_3 = CF::FormField.new({:label => "Last Name", :field_type => "SA", :required => "true"})
        line.stations.first.instruction.form_fields form_fields_3

        line.stations.first.instruction.form_fields[0].label.should eql("First Name")
        line.stations.first.instruction.form_fields[0].field_type.should eq("SA")
        line.stations.first.instruction.form_fields[0].required.should eq(true)
        line.stations.first.instruction.form_fields[1].label.should eql("Middle Name")
        line.stations.first.instruction.form_fields[1].field_type.should eq("SA")
        line.stations.first.instruction.form_fields[2].label.should eql("Last Name")
        line.stations.first.instruction.form_fields[2].field_type.should eq("SA")
        line.stations.first.instruction.form_fields[2].required.should eq(true)
      end
    end
  
    it "in block DSL way" do
      VCR.use_cassette "form-fields/block/create-using-block", :record => :new_episodes do
        line = CF::Line.create("Digitize Card", "Digitization") do
          CF::Station.create({:line => self, :type => "work"}) do |station|
            CF::InputHeader.new({:station => station, :label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
            CF::HumanWorker.new({:station => station, :number => 2, :reward => 20})
            CF::TaskForm.create({:station => station, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
              CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.title.should eq("Digitize Card")
        line.department_name.should eq("Digitization")
        line.stations.first.input_headers.first.label.should eql("image_url")
        line.stations.first.type.should eq("Work")
        line.stations.first.worker.number.should eq(2)
        line.stations.first.instruction.description.should eq("Describe")
        line.stations.first.instruction.form_fields[0].label.should eq("First Name")
        line.stations.first.instruction.form_fields[0].field_type.should eq("SA")
        line.stations.first.instruction.form_fields[0].required.should eq("true")
        line.stations.first.instruction.form_fields[1].label.should eq("Middle Name")
        line.stations.first.instruction.form_fields[1].field_type.should eq("SA")
        line.stations.first.instruction.form_fields[2].label.should eq("Last Name")
        line.stations.first.instruction.form_fields[2].field_type.should eq("SA")
        line.stations.first.instruction.form_fields[2].required.should eq("true")
      end
    end
  end
end