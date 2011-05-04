require 'spec_helper'

describe CloudFactory::StandardInstruction do
  context "create a stsandard_instruction" do
    it "the plain ruby way" do
      attrs = {:title => "Enter text from a business card image",
        :description => "Describe"}
        form_fields = []
        form_fields << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
        form_fields << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
        form_fields << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")
        
        instruction = CloudFactory::StandardInstruction.new(attrs)
        
        instruction_1 = CloudFactory::StandardInstruction.create(attrs) do |i|
          i.form_fields = form_fields
        end
        
        instruction.title.should eq("Enter text from a business card image")
        instruction.description.should eq("Describe")
        instruction_1.title.should eq("Enter text from a business card image")
        instruction_1.description.should eq("Describe")
        instruction_1.form_fields.first.label.should eq("First Name")
        instruction_1.form_fields.first.field_type.should eq("SA")
        instruction_1.form_fields.first.required.should eq("true")
      end
    end
  end