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

        line = CloudFactory::Line.new("Digitize Card","Digitization")
        line.title.should eq("Digitize Card")
        input_header = CloudFactory::InputHeader.new(line, attrs)
        line.input_headers[0].label.should eq("image_url")
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
        
        line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
          CloudFactory::InputHeader.new(l, attrs_1)
          CloudFactory::InputHeader.new(l, attrs_2)
        end
        input_headers_of_line = CloudFactory::InputHeader.all(line)
        input_headers_of_line.map(&:label).should include("image_url")
        input_headers_of_line.map(&:label).should include("text_url")
        input_headers_of_line.map(&:value).should include("http://s3.amazon.com/bizcardarmy/medium/1.jpg")
        input_headers_of_line.map(&:value).should include("http://s3.amazon.com/bizcardarmy/")
      end
    end
    
    it "should return info of an input header" do
      VCR.use_cassette "input_headers/get-input-header", :record => :new_episodes do
        attrs_1 = {:label => "image_url_type",
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
        
        line = CloudFactory::Line.create("Digitize","Digitization") do |l|
          CloudFactory::InputHeader.new(l, attrs_1)
          CloudFactory::InputHeader.new(l, attrs_2)
        end
        got_input_header = line.input_headers[0].get 
        got_input_header.label.should eq("image_url_type")
        got_input_header.field_type.should eq("text_data")
        got_input_header.value.should eq("http://s3.amazon.com/bizcardarmy/medium/1.jpg")
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
        
        line = CloudFactory::Line.create("Digitize","Digitization") do |l|
          CloudFactory::InputHeader.new(l, attrs_1)
        end
        line.input_headers.last.update({:label => "jackpot", :field_type => "lottery"})
        updated_input_header = line.input_headers.last.get
        updated_input_header.label.should eq("jackpot")
        updated_input_header.field_type.should eq("lottery")
      end
    end
  end
  
  context "delete input_headers" do
    xit "should delete all the input_headers of a specific line" do
      VCR.use_cassette "input_headers/delete-input-headers", :record => :new_episodes do
        attrs_1 = {:label => "image_url_0",
          :field_type => "text_data",
          :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
          :required => true, 
          :validation_format => "url"
        }
        attrs_2 = {:label => "image_url_1",
          :field_type => "text_data",
          :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
          :required => true, 
          :validation_format => "url"
        }
        attrs_3 = {:label => "image_url_2",
          :field_type => "text_data",
          :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
          :required => true, 
          :validation_format => "url"
        }
        
        line = CloudFactory::Line.create("Digitize","Digitization") do |l|
          CloudFactory::InputHeader.new(l, attrs_1)
          CloudFactory::InputHeader.new(l, attrs_2)
          CloudFactory::InputHeader.new(l, attrs_3)
        end
        
        CloudFactory::InputHeader.delete_all(line)
        
        begin
          CloudFactory::InputHeader.all(line)
        rescue Exception => exec
          exec.class.should eql(NoMethodError)
        end
      end
    end
  end
  
  context "delete an input_header" do
    it "should delete an input_header of a specific line" do
      VCR.use_cassette "input_headers/delete-input-header", :record => :new_episodes do
        attrs_1 = {:label => "image_url_type",
          :field_type => "text_data",
          :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
          :required => true, 
          :validation_format => "url"
        }
        
        line = CloudFactory::Line.create("Digitize","Digitization") do |l|
          CloudFactory::InputHeader.new(l, attrs_1)
        end
        
        line.input_headers[0].delete
        
        begin
          line.input_headers[0].get
        rescue Exception => exec
          exec.class.should eql(Crack::ParseError)
        end
      end
    end
  end
end