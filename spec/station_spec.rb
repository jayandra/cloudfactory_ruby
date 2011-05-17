require 'spec_helper'

describe CloudFactory::Station do
  context "create a station" do
    it "the plain ruby way" do
      VCR.use_cassette "stations/create", :record => :new_episodes do
        line = CloudFactory::Line.new("Digitize Card","Digitization")
        line.title.should eq("Digitize Card")
        station = CloudFactory::Station.new(line, :type => "Work")
        station.type.should eq("Work")
      end
    end

    it "using the block variable" do
      VCR.use_cassette "stations/create-with-block-var", :record => :new_episodes do
        form_fields = []
        
        line = CloudFactory::Line.new("Digitize Card","Digitization")
        line.title.should eq("Digitize Card")

        station = CloudFactory::Station.create(line, :type => "work") do |s|
          worker = CloudFactory::HumanWorker.new(s, 2, 0.2)
          s.worker = worker
          s.instruction = CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
            form_fields << CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
            form_fields << CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
            form_fields << CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})
            
            i.form_fields = form_fields
          end
        end
        station.type.should eq("Work")
        station.worker.number.should == 2
        station.worker.reward.should == 0.2
      end
    end

    it "using without the block variable also creating instruction without block variable" do
      VCR.use_cassette "stations/create-without-block-var", :record => :new_episodes do
        form_fields = []
        line = CloudFactory::Line.new("Digitize Card","Digitization")
        line.title.should eq("Digitize Card")
        
        station_1 = CloudFactory::Station.create(line, :type => "Work") do 
          human_worker = CloudFactory::HumanWorker.new(self, 2, 0.2)
          s = self
          worker human_worker
          instruction = CloudFactory::StandardInstruction.create(self,{:title => "Enter text from a business card image", :description => "Describe"}) do 
            form_fields << CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
            form_fields << CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
            form_fields << CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})
            form_fields form_fields
          end 
        end
        station_1.type.should eq("Work")
        station_1.worker.number.should == 2
        station_1.worker.reward.should == 0.2
      end
    end

    it "create a custom instruction" do
      VCR.use_cassette "stations/create-instruction", :record => :new_episodes do
          attrs = {:title => "Enter text from a business card image",
          :description => "Describe"
          }
          html =   
          '<div id="form-content">
            <div id="instructions">
              <ul>
                <li>Look at the business card properly and fill in asked data.</li>
                <li>Make sure you enter everything found on business card.</li>
                <li>Work may be rejected if it is incomplete or mistakes are found.</li>
              </ul>
            </div>
            <div id="image-field-wrapper">
              <div id = "image-panel" >
                <img class="card-mage" src="{{image_url}}">
              </div>
              <div id = "field-panel">
                Name<br />
                <input class="input-field first_name" type="text" name="result[first_name]" />
                <input class="input-field middle_name" type="text" name="result[middle_name]" />
                <input class="input-field last_name" type="text" name="result[last_name]" /><br />
                <br />Contact<br />
                <input class="input-field email" type="text" name="result[email]" placeholder="Email"/>
                <input class="input-field phone" type="text" name="result[phone]" placeholder="Phone"/>
                <input class="input-field mobile" type="text" name="result[mobile]" placeholder="Mobile"/><br />
              </div>
            </div>
          </div>'

          css = 
          'body {background:#fbfbfb;}
          #instructions{
          text-align:center;
          }
          #image-field-wrapper{
          float-left;
          min-width:1050px;
          overflow:hidden;
          }
          #field-panel{
          float:left;
          padding: 10px 10px 0 10px;
          min-width:512px;
          overflow:hidden;
          }
          .input-field{
          width:150px;
          margin:4px;
          }'

          javascript = 
            '<script src="http://code.jquery.com/jquery-latest.js"></script>
            <script type="text/javascript" src="http://www.bizcardarmy.com/javascripts/jquery.autocomplete-min.js"></script>
            <script type="text/javascript">
            $(document).ready(function(){
              autocomplete_fields = ["first_name", "middle_name", "last_name", "company", "job_title", "city", "state", "zip"];
              $.each(autocomplete_fields, function(index, value){
                var inputField = "input." + value;
                $(inputField).autocomplete({
                  serviceUrl: "http://www.bizcardarmy.com/cards/return_data_for_autocompletion.json",
                  maxHeight: 400,
                  width: 300,
                  zIndex: 9999,
                  params: { field: value }
                });
              });
            });
            </script>'

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

      context "updating a station" do
        it "should update a station" do
          VCR.use_cassette "stations/update", :record => :new_episodes do
            line = CloudFactory::Line.new("Digitize Card","Digitization")
            line.title.should eq("Digitize Card")
            station = CloudFactory::Station.new(line, {:type => "Work"})
            station.type.should eq("Work")
            station.update({:type => "Tournament"})
            station.type.should eq("Tournament")
            station.type.should_not eq("Work")
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
            station.get_station._type.should eq("WorkStation")
          end
        end

        it "should get all existing stations of a line" do
          VCR.use_cassette "stations/get-all-stations", :record => :new_episodes do
            line = CloudFactory::Line.create("Digitize Card", "Digitization") do |l|
              station = []
              station << CloudFactory::Station.new(l, :type => "work")
              station << CloudFactory::Station.new(l, :type => "Tournament")
              l.stations = station
            end
            stations = CloudFactory::Station.all(line)
            stations[0]._type.should eq("WorkStation")
            stations[1]._type.should eq("TournamentStation")
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
              station.get_station
            rescue Exception => exec
              exec.class.should eql(Crack::ParseError)
            end
          end
        end
      end

    end