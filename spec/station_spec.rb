require 'spec_helper'

describe CloudFactory::Station do
  context "create a station" do
    it "the plain ruby way" do
      VCR.use_cassette "stations/create", :record => :new_episodes do
        line = CloudFactory::Line.new("Digitize Card","Digitization")
        line.title.should eq("Digitize Card")
        station = CloudFactory::Station.new(line, :type => "Work")
        station.type.should eq("Work")
        line.stations.first.type.should eq("Work")
      end
    end

    it "using the block variable" do
      VCR.use_cassette "stations/create-with-block-var", :record => :new_episodes do
        line = CloudFactory::Line.new("Digitize Card","Digitization")
        line.title.should eq("Digitize Card")

        station = CloudFactory::Station.create(line, :type => "work") do |s|
          CloudFactory::HumanWorker.new(s, 2, 20)
          CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
            CloudFactory::FormField.new(i, {:label => "First Name", :field_type => "SA", :required => "true"})
            CloudFactory::FormField.new(i, {:label => "Middle Name", :field_type => "SA"})
            CloudFactory::FormField.new(i, {:label => "Last Name", :field_type => "SA", :required => "true"})
          end
        end
        line.stations.first.type.should eq("Work")
        line.stations.first.worker.number.should == 2
        line.stations.first.worker.reward.should == 20
        line.stations.first.instruction.title.should eq("Enter text from a business card image")
        line.stations.first.instruction.description.should eq("Describe")
        line.stations.first.instruction.form_fields[0].label.should eq("First Name")
        line.stations.first.instruction.form_fields[1].label.should eq("Middle Name")
        line.stations.first.instruction.form_fields[2].label.should eq("Last Name")
      end
    end

    it "using without the block variable also creating instruction without block variable" do
      VCR.use_cassette "stations/create-without-block-var", :record => :new_episodes do
        line = CloudFactory::Line.new("Digitize Card","Digitization")
        line.title.should eq("Digitize Card")

        station_1 = CloudFactory::Station.create(line, :type => "Work") do 
          human_worker = CloudFactory::HumanWorker.new(self, 2, 20)
          CloudFactory::StandardInstruction.create(self,{:title => "Enter text from a business card image", :description => "Describe"}) do 
            CloudFactory::FormField.new(self, {:label => "First Name", :field_type => "SA", :required => "true"})
            CloudFactory::FormField.new(self, {:label => "Middle Name", :field_type => "SA"})
            CloudFactory::FormField.new(self, {:label => "Last Name", :field_type => "SA", :required => "true"})
          end 
        end
        line.stations.first.type.should eq("Work")
        line.stations.first.worker.number.should == 2
        line.stations.first.worker.reward.should == 20
        line.stations.first.instruction.title.should eq("Enter text from a business card image")
        line.stations.first.instruction.description.should eq("Describe")
        line.stations.first.instruction.form_fields[0].label.should eq("First Name")
        line.stations.first.instruction.form_fields[1].label.should eq("Middle Name")
        line.stations.first.instruction.form_fields[2].label.should eq("Last Name")
      end
    end

    it "should create a custom instruction" do
      VCR.use_cassette "stations/create-custom-instruction", :record => :new_episodes do
        attrs = {:title => "Enter text from a business card image",
          :description => "Describe"
        }
        html ='<div id="form-content"><div id="instructions"><ul><li>Look at the business card properly and fill in asked data.</li><li>Make sure you enter everything found on business card.</li><li>Work may be rejected if it is incomplete or mistakes are found.</li></ul></div><div id="image-field-wrapper"><div id = "image-panel" ><img class="card-mage" src="{{image_url}}"></div><div id = "field-panel">Name<br /><input class="input-field first_name" type="text" name="result[first_name]" /><input class="input-field middle_name" type="text" name="result[middle_name]" /><input class="input-field last_name" type="text" name="result[last_name]" /><br /><br />Contact<br /><input class="input-field email" type="text" name="result[email]" placeholder="Email"/><input class="input-field phone" type="text" name="result[phone]" placeholder="Phone"/><input class="input-field mobile" type="text" name="result[mobile]" placeholder="Mobile"/><br /></div></div></div>'

        css = 'body {background:#fbfbfb;}#instructions{text-align:center;}#image-field-wrapper{float-left;min-width:1050px;overflow:hidden;}#field-panel{float:left;padding: 10px 10px 0 10px;min-width:512px;overflow:hidden;}.input-field{width:150px;margin:4px;}'

        javascript = '<script src="http://code.jquery.com/jquery-latest.js"></script><script type="text/javascript" src="http://www.bizcardarmy.com/javascripts/jquery.autocomplete-min.js"></script><script type="text/javascript">$(document).ready(function(){autocomplete_fields = ["first_name", "middle_name", "last_name", "company", "job_title", "city", "state", "zip"];$.each(autocomplete_fields, function(index, value){var inputField = "input." + value;$(inputField).autocomplete({serviceUrl: "http://www.bizcardarmy.com/cards/return_data_for_autocompletion.json",maxHeight: 400,width: 300,zIndex: 9999,params: { field: value }});});});</script>'

        instruction = CloudFactory::CustomInstruction.create(attrs) do |i|
          i.html = html 
          i.css = css
          i.javascript = javascript
        end
        line = CloudFactory::Line.new("Digitize Card","Digitization")
        line.title.should eq("Digitize Card")

        station = CloudFactory::Station.create(line, :type => "work") do |s|
          s.instruction = instruction
        end
        station.type.should eq("Work")
        station.instruction.html.should == html
        station.instruction.css.should == css
        station.instruction.javascript.should == javascript
      end
    end
  end
 
  context "get station" do
    it "should get information about a single station" do
      VCR.use_cassette "stations/get-station", :record => :new_episodes do
        line = CloudFactory::Line.new("Digitize Card","Digitization")
        line.title.should eq("Digitize Card")
        station = CloudFactory::Station.new(line, :type => "Work")
        station.type.should eq("Work")
        line.stations.first.get._type.should eq("WorkStation")
      end
    end

    it "should get all existing stations of a line" do
      VCR.use_cassette "stations/get-all-stations", :record => :new_episodes do
        line = CloudFactory::Line.create("Digitize Card", "Digitization") do |l|
          CloudFactory::Station.new(l, :type => "work")
        end
        stations = CloudFactory::Station.all(line)
        stations[0]._type.should eq("WorkStation")
      end
    end
  end

  context "deleting a station" do
    it "should delete a station" do
      VCR.use_cassette "stations/delete", :record => :new_episodes do
        line = CloudFactory::Line.new("Digitize Card","Digitization")
        line.title.should eq("Digitize Card")
        station = CloudFactory::Station.new(line, :type => "Work")
        station.type.should eq("Work")
        station.delete
        begin
          station.get
        rescue Exception => exec
          exec.class.should eql(Crack::ParseError)
        end
      end
    end
  end

end