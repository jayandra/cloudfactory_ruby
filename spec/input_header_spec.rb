require 'spec_helper'

describe CloudFactory::InputHeader do
  context "create an input header" do
    it "the plain ruby way" do
      VCR.use_cassette "input_headers/create", :record => :new_episodes do
        attrs = {:label => "image_url",
          :field_type => "text_data",
          :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
          :required => true, 
          :validation_format => "url"
        }

        line = CloudFactory::Line.new("Digitize Card","4dc8ad6572f8be0600000001")
        line.title.should eq("Digitize Card")
        input_header = CloudFactory::InputHeader.new(line, attrs)
        input_header.label.should eq("image_url")
        input_header.field_type.should eq("text_data")
        input_header.value.should eq("http://s3.amazon.com/bizcardarmy/medium/1.jpg")
        input_header.required.should eq(true)
        input_header.validation_format.should eq("url")
      end
    end
  end

  context "return all the input headers" do
    it "should return all the input headers of a line " do
      VCR.use_cassette "input_headers/input-headers-of-line", :record => :new_episodes do
        attrs_1 = {:label => "image_url",
          :field_type => "text_data",
          :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
          :required => true, 
          :validation_format => "url"
        }
        attrs_2 = {:label => "text_url",
          :field_type => "text_data",
          :value => "http://s3.amazon.com/bizcardarmy/", 
          :required => true, 
          :validation_format => "url"
        }
        
        line = CloudFactory::Line.create("Digitize Card","4dc8ad6572f8be0600000001") do |l|
          input_header_1 = CloudFactory::InputHeader.new(l, attrs_1)
          input_header_2 = CloudFactory::InputHeader.new(l, attrs_2)
          
          l.input_headers = [input_header_1,input_header_2]
        end
        input_headers_of_line = CloudFactory::InputHeader.get_input_headers_of_line(line)
        input_headers_of_line.map(&:label).should include("image_url")
        input_headers_of_line.map(&:label).should include("text_url")
        input_headers_of_line.map(&:value).should include("http://s3.amazon.com/bizcardarmy/medium/1.jpg")
        input_headers_of_line.map(&:value).should include("http://s3.amazon.com/bizcardarmy/")
      end
    end
    
    it "should return info of a input header" do
      VCR.use_cassette "input_headers/get-input-header", :record => :new_episodes do
        attrs_1 = {:label => "image_url_type",
          :field_type => "text_data",
          :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
          :required => true, 
          :validation_format => "url"
        }
        
        line = CloudFactory::Line.create("Digitize","4dc8ad6572f8be0600000006") do |l|
          input_header_1 = CloudFactory::InputHeader.new(l, attrs_1)
          l.input_headers = [input_header_1]
        end
        input_headers_of_line = CloudFactory::InputHeader.get_input_headers_of_line(line)
        input_header = input_headers_of_line.last
        got_input_header = CloudFactory::InputHeader.get_input_header(line, input_header)
        input_header.label.should eq("image_url_type")
        input_header.field_type.should eq("text_data")
        input_header.value.should eq("http://s3.amazon.com/bizcardarmy/medium/1.jpg")
      end
    end
  end
  
  context "update input_header" do
    it "should update input_header" do
      VCR.use_cassette "input_headers/update-input-header", :record => :new_episodes do
        attrs_1 = {:label => "image_url_type",
          :field_type => "text_data",
          :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
          :required => true, 
          :validation_format => "url"
        }
        
        line = CloudFactory::Line.create("Digitize","4dc8ad6572f8be0600000006") do |l|
          input_header_1 = CloudFactory::InputHeader.new(l, attrs_1)
          l.input_headers = [input_header_1]
        end
        input_header = CloudFactory::InputHeader.get_input_headers_of_line(line).first
        updated_input_header = CloudFactory::InputHeader.update(line, input_header, {:label => "jackpot", :field_type => "lottery"})
        updated_input_header.parsed_response['label'].should eq("jackpot")
        updated_input_header.parsed_response['field_type'].should eq("lottery")
      end
    end
  end
end