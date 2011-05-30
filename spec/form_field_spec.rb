require 'spec_helper'

describe CloudFactory::FormField do
  context "create an form_field" do
    it "the plain ruby way" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "form_fields/create", :record => :new_episodes do
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
end