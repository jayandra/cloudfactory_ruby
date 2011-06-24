require 'spec_helper'

describe CF::InputFormat do
  context "create an input header" do
    it "in plain ruby way within line" do
      VCR.use_cassette "input_formats/plain-ruby/create-within-line", :record => :new_episodes do
        attrs = {:name => "image_url",
          :required => true, 
          :valid_type => "url"
        }

        line = CF::Line.new("Digitize Card","Digitization")
        input_format = CF::InputFormat.new(attrs)
        line.input_formats input_format
        line.input_formats.first.name.should eql("image_url")
        line.input_formats.first.valid_type.should eql("url")
      end
    end
    
    it "in plain ruby way within station" do
      VCR.use_cassette "input_formats/plain-ruby/create", :record => :new_episodes do
        attrs = {:name => "image_url",
          :required => true, 
          :valid_type => "url"
        }

        line = CF::Line.new("Digitize Card","Digitization")
        station = CF::Station.new({:type => "work"})
        line.stations station
        input_format = CF::InputFormat.new(attrs)
        line.stations.first.input_formats input_format

        line.title.should eq("Digitize Card")
        line.stations.first.input_formats.first.name.should eq("image_url")
        line.stations.first.input_formats.first.required.should eq(true)
        line.stations.first.input_formats.first.valid_type.should eq("url")
      end
    end
    
    it "in block DSL way within line" do
      VCR.use_cassette "input_formats/block/create-input-headers-of-line", :record => :new_episodes do 
        line = CF::Line.create("Digitize Card","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
            CF::InputFormat.new({:line => l, :name => "image", :required => true, :valid_type => "url"})
        end
        line.input_formats[0].name.should eq("image_url")
        line.input_formats[1].name.should eq("image")
      end
    end
    
    it "in block DSL way within station" do
      VCR.use_cassette "input_formats/block/create-input-headers-of-station", :record => :new_episodes do 
        line = CF::Line.create("Digitize Card","Digitization") do |l|
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::InputFormat.new({:station => s, :name => "image_url", :required => true, :valid_type => "url"})
            CF::InputFormat.new({:station => s, :name => "image", :required => true, :valid_type => "url"})
          end
        end
        line.stations.first.input_formats[0].name.should eq("image_url")
        line.stations.first.input_formats[1].name.should eq("image")
      end
    end
  end

  context "return all the input headers" do
    it "should return all the input headers of a line " do
      VCR.use_cassette "input_formats/block/input-headers-of-line", :record => :new_episodes do 
        line = CF::Line.create("Digitize Card","Digitization") do |l|
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::InputFormat.new({:station => s, :name => "image_url", :required => true, :valid_type => "url"})
            CF::InputFormat.new({:station => s, :name => "image", :required => true, :valid_type => "url"})
          end
        end
        input_formats_of_line = CF::InputFormat.all(line)
        input_formats_of_line.map(&:name).should include("image_url")
        input_formats_of_line.map(&:name).should include("image")
        input_formats_of_line.map(&:valid_type).should include("url")
      end
    end

    it "should return info of an input header" do
      VCR.use_cassette "input_formats/block/get-input-header", :record => :new_episodes do
        line = CF::Line.create("Digitize Card","Digitization") do |l|
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::InputFormat.new({:station => s, :name => "image_url", :required => true, :valid_type => "url"})
            CF::InputFormat.new({:station => s, :name => "image", :required => true, :valid_type => "url"})
          end
        end
        got_input_format_1 = line.stations.first.input_formats[0].get 
        got_input_format_1.name.should eq("image_url")

        got_input_format_2 = line.stations.first.input_formats[1].get 
        got_input_format_2.name.should eq("image")
      end
    end
  end

  context "update input_format" do
    it "should update input_format" do
      VCR.use_cassette "input_formats/block/update-input-header", :record => :new_episodes do
        line = CF::Line.create("Digitize Card","Digitization") do |l|
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::InputFormat.new({:station => s, :name => "image_url", :required => true, :valid_type => "url"})
            CF::InputFormat.new({:station => s, :name => "image", :required => true, :valid_type => "url"})
          end
        end
        line.stations.first.input_formats.last.update({:name => "jackpot"})
        updated_input_format = line.stations.first.input_formats.last.get
        updated_input_format.name.should eq("jackpot")
      end
    end
  end

  context "delete an input_format" do
    it "should delete an input_format of a specific line" do
      VCR.use_cassette "input_formats/block/delete-input-header", :record => :new_episodes do
        line = CF::Line.create("Digitize Card","Digitization") do |l|
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::InputFormat.new({:station => s, :name => "image_url", :required => true, :valid_type => "url"})
            CF::InputFormat.new({:station => s, :name => "image", :required => true, :valid_type => "url"})
          end
        end
        input_format = line.stations.first.input_formats[0].delete
        input_format['message'].should eql ("succesfully deleted")
      end
    end
  end
end