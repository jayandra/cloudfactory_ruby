require 'spec_helper'

describe CloudFactory::InputHeader do
  context "create an input header" do
    it "the plain ruby way" do
      attrs = {:label => "image_url",
          :field_type => "text_data",
          :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
          :required => true, 
          :validation_format => "url"}
          
      input_header = CloudFactory::InputHeader.new(attrs)
      input_header.label.should eq("image_url")
      input_header.field_type.should eq("text_data")
      input_header.value.should eq("http://s3.amazon.com/bizcardarmy/medium/1.jpg")
      input_header.required.should eq(true)
      input_header.validation_format.should eq("url")
    end
  end
end