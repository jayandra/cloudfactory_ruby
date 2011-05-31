require 'spec_helper'

describe CloudFactory::StandardInstruction do
  context "create a standard_instruction" do
    it "the plain ruby way" do
      VCR.use_cassette "standard_instruction/create", :record => :new_episodes do
        attrs = {:title => "Enter text from a business card image",
          :description => "Describe"
        }
        
        line = CloudFactory::Line.create("Digitize Card", "Digitization") do |l|
          CloudFactory::Station.create(l, :type => "work") do |s|
            CloudFactory::StandardInstruction.create(s, attrs) do |i|
              CloudFactory::FormField.new(i, {:label => "First Name", :field_type => "SA", :required => "true"})
              CloudFactory::FormField.new(i, {:label => "Middle Name", :field_type => "SA"})
              CloudFactory::FormField.new(i, {:label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        instruction = line.stations[0].instruction
        instruction.title.should eq("Enter text from a business card image")
        instruction.description.should eq("Describe")
        instruction.form_fields.first.label.should eq("First Name")
        instruction.form_fields.first.field_type.should eq("SA")
        instruction.form_fields.first.required.should eq("true")
      end
    end
  end
  
  context "get instruction info" do
    it "should get all the instruction information of a station" do
      VCR.use_cassette "standard_instruction/get-instruction", :record => :new_episodes do
        attrs = {:title => "Enter text from a business card image",
          :description => "Describe"
        }

        line = CloudFactory::Line.create("Digitize Card", "Digitization") do |l|
          CloudFactory::Station.create(l, :type => "work") do |s|
            CloudFactory::StandardInstruction.create(s, attrs) do |i|
              CloudFactory::FormField.new(i, {:label => "First Name", :field_type => "SA", :required => "true"})
              CloudFactory::FormField.new(i, {:label => "Middle Name", :field_type => "SA"})
              CloudFactory::FormField.new(i, {:label => "Last Name", :field_type => "SA", :required => "true"})
            end
            @got_instruction = s.get_instruction
          end
        end
        @got_instruction.title.should eq("Enter text from a business card image")
        @got_instruction.description.should eq("Describe")
      end
    end
  end
  
  context "update instruction" do
    it "should update instruction information of a station" do
      pending "Instruction update is not implemented in the RESTful API"
      # VCR.use_cassette "standard_instruction/update-instruction", :record => :new_episodes do
      
        attrs = {:title => "Enter text from a business card image",
          :description => "Describe"
        }

        line = CloudFactory::Line.create("Digitize Card", "Digitization") do |l|
          CloudFactory::Station.create(l, :type => "work") do |s|
            CloudFactory::StandardInstruction.create(s, attrs) do |i|
              CloudFactory::FormField.new(i, {:label => "First Name", :field_type => "SA", :required => "true"})
              CloudFactory::FormField.new(i, {:label => "Middle Name", :field_type => "SA"})
              CloudFactory::FormField.new(i, {:label => "Last Name", :field_type => "SA", :required => "true"})
            end
            @got_instruction = s.get_instruction
            s.update_instruction({:title => "Enter phone number from a business card image", :description => "Call"})
            @updated_instruction = s.get_instruction
          end
        end
        @got_instruction.title.should eq("Enter text from a business card image")
        @got_instruction.description.should eq("Describe")
        @updated_instruction.title.should eq("Enter phone number from a business card image")
        @updated_instruction.description.should eq("Call")
      # end
    end
  end
  
  context "Delete instruction" do
    it "should delete instruction of a station" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "standard_instruction/delete-instruction", :record => :new_episodes do
        attrs = {:title => "Enter text from a business card image",
          :description => "Describe"
        }

        form_fields = []
  
        line = CloudFactory::Line.create("Digitize Card", "Digitization") do |l|
          CloudFactory::Station.create(l, :type => "work") do |s|
            CloudFactory::StandardInstruction.create(s, attrs) do |i|
              CloudFactory::FormField.new(i, {:label => "First Name", :field_type => "SA", :required => "true"})
              CloudFactory::FormField.new(i, {:label => "Middle Name", :field_type => "SA"})
              CloudFactory::FormField.new(i, {:label => "Last Name", :field_type => "SA", :required => "true"})
              i.form_fields = form_fields
            end
            @got_instruction = s.get_instruction
          end
        end
        @got_instruction.title.should eq("Enter text from a business card image")
        @got_instruction.description.should eq("Describe")
        
        station = line.stations[0]
        deleted_response = CloudFactory::StandardInstruction.delete_instruction(station)
        deleted_response.code.should eq(200)
      end
    end
  end
end