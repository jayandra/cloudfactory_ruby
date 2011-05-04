require 'spec_helper'

describe CloudFactory::FormField do
  context "create an form_field" do
    it "the plain ruby way" do
      attrs = {:label => "First Name",
          :field_type => "SA",
          :required => true}
          
      form_field = CloudFactory::FormField.new(attrs)
      form_field.label.should eq("First Name")
      form_field.field_type.should eq("SA")
      form_field.required.should eq(true)
    end
  end
end