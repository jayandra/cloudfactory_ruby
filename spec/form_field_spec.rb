require 'spec_helper'

describe CloudFactory::FormField do
  context "create an form_field" do
    it "the plain ruby way" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "standard_instruction/create", :record => :new_episodes do
        attrs = {:title => "Enter text from a business card image",
          :description => "Describe"
        }

        form_fields = []

        line = CloudFactory::Line.create("Digitize Card", "Digitization") do |l|
          l.stations = CloudFactory::Station.create(l, :type => "work") do |s|
            s.instruction = CloudFactory::StandardInstruction.create(s, attrs) do |i|
              form_fields << CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
              form_fields << CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
              form_fields << CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})

              i.form_fields = form_fields
            end
          end
        end
        instruction = line.stations.instruction
        instruction.title.should eq("Enter text from a business card image")
        instruction.description.should eq("Describe")
        instruction.form_fields.first.label.should eq("First Name")
        instruction.form_fields.first.field_type.should eq("SA")
        instruction.form_fields.first.required.should eq("true")
      end
    end
  end
end