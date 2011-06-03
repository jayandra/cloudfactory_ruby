require 'spec_helper'

describe CloudFactory::InputHeader do
  context "create an input header" do
    it "in plain ruby way within line" do
      VCR.use_cassette "input_headers/plain-ruby/create-within-line", :record => :new_episodes do
        attrs = {:label => "image_url",
          :field_type => "text_data",
          :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
          :required => true, 
          :validation_format => "url"
        }

        line = CloudFactory::Line.new("Digitize Card","Digitization")
        input_header = CloudFactory::InputHeader.new(attrs)
        line.input_headers input_header
        line.input_headers.first.label.should eql("image_url")
        line.input_headers.first.field_type.should eql("text_data")
      end
    end
    
    it "in plain ruby way within station" do
      VCR.use_cassette "input_headers/plain-ruby/create", :record => :new_episodes do
        attrs = {:label => "image_url",
          :field_type => "text_data",
          :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
          :required => true, 
          :validation_format => "url"
        }

        line = CloudFactory::Line.new("Digitize Card","Digitization")
        station = CloudFactory::Station.new({:type => "work"})
        line.stations station
        input_header = CloudFactory::InputHeader.new(attrs)
        line.stations.first.input_headers input_header

        line.title.should eq("Digitize Card")
        line.stations.first.input_headers.first.label.should eq("image_url")
        line.stations.first.input_headers.first.field_type.should eq("text_data")
        line.stations.first.input_headers.first.value.should eq("http://s3.amazon.com/bizcardarmy/medium/1.jpg")
        line.stations.first.input_headers.first.required.should eq("true")
        line.stations.first.input_headers.first.validation_format.should eq("url")
      end
    end
    
    it "in block DSL way within line" do
      VCR.use_cassette "input_headers/block/create-input-headers-of-line", :record => :new_episodes do 
        line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
            CloudFactory::InputHeader.new({:line => l, :label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
            CloudFactory::InputHeader.new({:line => l, :label => "image",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/", :required => true, :validation_format => "url"})
        end
        line.input_headers[0].label.should eq("image_url")
        line.input_headers[0].field_type.should eq("text_data")
        line.input_headers[0].value.should eq("http://s3.amazon.com/bizcardarmy/medium/1.jpg")
        line.input_headers[1].label.should eq("image")
        line.input_headers[1].field_type.should eq("text_data")
        line.input_headers[1].value.should eq("http://s3.amazon.com/bizcardarmy/")
      end
    end
    
    it "in block DSL way within station" do
      VCR.use_cassette "input_headers/block/create-input-headers-of-station", :record => :new_episodes do 
        line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
          CloudFactory::Station.create({:line => l, :type => "work"}) do |s|
            CloudFactory::InputHeader.new({:station => s, :label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
            CloudFactory::InputHeader.new({:station => s, :label => "image",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/", :required => true, :validation_format => "url"})
          end
        end
        line.stations.first.input_headers[0].label.should eq("image_url")
        line.stations.first.input_headers[0].field_type.should eq("text_data")
        line.stations.first.input_headers[0].value.should eq("http://s3.amazon.com/bizcardarmy/medium/1.jpg")
        line.stations.first.input_headers[1].label.should eq("image")
        line.stations.first.input_headers[1].field_type.should eq("text_data")
        line.stations.first.input_headers[1].value.should eq("http://s3.amazon.com/bizcardarmy/")
      end
    end
  end

  context "return all the input headers" do
    it "should return all the input headers of a line " do
      VCR.use_cassette "input_headers/block/input-headers-of-line", :record => :new_episodes do 
        line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
          CloudFactory::Station.create({:line => l, :type => "work"}) do |s|
            CloudFactory::InputHeader.new({:station => s, :label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
            CloudFactory::InputHeader.new({:station => s, :label => "image",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/", :required => true, :validation_format => "url"})
          end
        end
        input_headers_of_line = CloudFactory::InputHeader.all(line)
        input_headers_of_line.map(&:label).should include("image_url")
        input_headers_of_line.map(&:label).should include("image")
        input_headers_of_line.map(&:field_type).should include("text_data")
        input_headers_of_line.map(&:validation_format).should include("url")
        input_headers_of_line.map(&:value).should include("http://s3.amazon.com/bizcardarmy/medium/1.jpg")
        input_headers_of_line.map(&:value).should include("http://s3.amazon.com/bizcardarmy/")
      end
    end

    it "should return info of an input header" do
      VCR.use_cassette "input_headers/block/get-input-header", :record => :new_episodes do
        line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
          CloudFactory::Station.create({:line => l, :type => "work"}) do |s|
            CloudFactory::InputHeader.new({:station => s, :label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
            CloudFactory::InputHeader.new({:station => s, :label => "image",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/", :required => true, :validation_format => "url"})
          end
        end
        got_input_header_1 = line.stations.first.input_headers[0].get 
        got_input_header_1.label.should eq("image_url")
        got_input_header_1.field_type.should eq("text_data")
        got_input_header_1.value.should eq("http://s3.amazon.com/bizcardarmy/medium/1.jpg")

        got_input_header_2 = line.stations.first.input_headers[1].get 
        got_input_header_2.label.should eq("image")
        got_input_header_2.field_type.should eq("text_data")
        got_input_header_2.value.should eq("http://s3.amazon.com/bizcardarmy/")
      end
    end
  end

  context "update input_header" do
    it "should update input_header" do
      VCR.use_cassette "input_headers/block/update-input-header", :record => :new_episodes do
        line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
          CloudFactory::Station.create({:line => l, :type => "work"}) do |s|
            CloudFactory::InputHeader.new({:station => s, :label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
            CloudFactory::InputHeader.new({:station => s, :label => "image",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/", :required => true, :validation_format => "url"})
          end
        end
        line.stations.first.input_headers.last.update({:label => "jackpot", :field_type => "lottery"})
        updated_input_header = line.stations.first.input_headers.last.get
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
      VCR.use_cassette "input_headers/block/delete-input-header", :record => :new_episodes do
        line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
          CloudFactory::Station.create({:line => l, :type => "work"}) do |s|
            CloudFactory::InputHeader.new({:station => s, :label => "image_url",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
            CloudFactory::InputHeader.new({:station => s, :label => "image",:field_type => "text_data",:value => "http://s3.amazon.com/bizcardarmy/", :required => true, :validation_format => "url"})
          end
        end
        line.stations.first.input_headers[0].delete

        begin
          line.stations.first.input_headers[0].get
        rescue Exception => exec
          exec.class.should eql(Crack::ParseError)
        end
      end
    end
  end
end