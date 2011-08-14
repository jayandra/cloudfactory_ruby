require 'spec_helper'

describe CF::Station do
  context "create a station" do
    it "the plain ruby way" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "stations/plain-ruby/create", :record => :new_episodes do
        line = CF::Line.new("Digitize--ard", "Digitization")
        station = CF::Station.new({:type => "work"})
        line.stations station
        line.stations.first.type.should eql("WorkStation")
      end
    end

    it "using the block variable" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "stations/block/create-with-block-var", :record => :new_episodes do
        line = CF::Line.create("igitizeard", "Digitization") do
          CF::Station.create({:line => self, :type => "work"}) do |s|
            CF::HumanWorker.new({:station => s, :number => 2, :reward => 20})
            CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
              CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.stations.first.type.should eq("WorkStation")
        line.stations.first.worker.number.should eql(2)
        line.stations.first.worker.reward.should eql(20)
        line.stations.first.form.title.should eq("Enter text from a business card image")
        line.stations.first.form.instruction.should eq("Describe")
        line.stations.first.form.form_fields[0].label.should eq("First Name")
        line.stations.first.form.form_fields[1].label.should eq("Middle Name")
        line.stations.first.form.form_fields[2].label.should eq("Last Name")
      end
    end

    it "using without the block variable also creating instruction without block variable" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "stations/block/create-without-block-var", :record => :new_episodes do
        line = CF::Line.create("Digitizrd", "Digitization") do
          CF::Station.create({:line => self, :type => "work"}) do
            CF::HumanWorker.new({:station => self, :number => 2, :reward => 20})
            CF::TaskForm.create({:station => self, :title => "Enter text from a business card image", :instruction => "Describe"}) do
              CF::FormField.new({:form => self, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:form => self, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:form => self, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.stations.first.type.should eq("WorkStation")
        line.stations.first.worker.number.should == 2
        line.stations.first.worker.reward.should == 20
        line.stations.first.form.title.should eq("Enter text from a business card image")
        line.stations.first.form.instruction.should eq("Describe")
        line.stations.first.form.form_fields[0].label.should eq("First Name")
        line.stations.first.form.form_fields[1].label.should eq("Middle Name")
        line.stations.first.form.form_fields[2].label.should eq("Last Name")
      end
    end

    it "should create a station of Tournament station" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "stations/block/tournament-station", :record => :new_episodes do
        line = CF::Line.create("Digitized-9", "Digitization") do
          CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line => self, :type => "tournament", :jury_worker=> {:max_judges => 10}, :auto_judge => {:enabled => true}}) do |s|
            CF::HumanWorker.new({:station => s, :number => 3, :reward => 20})
            CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
              CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.stations.first.type.should eq("TournamentStation")
        line.stations.first.jury_worker.should eql({:max_judges => 10})
        line.stations.first.auto_judge.should eql({:enabled => true})
        line.stations.first.worker.number.should eql(3)
        line.stations.first.worker.reward.should eql(20)
        line.stations.first.form.title.should eq("Enter text from a business card image")
        line.stations.first.form.instruction.should eq("Describe")
        line.stations.first.form.form_fields[0].label.should eq("First Name")
        line.stations.first.form.form_fields[1].label.should eq("Middle Name")
        line.stations.first.form.form_fields[2].label.should eq("Last Name")
      end
    end

    it "should create a station of Improve station as first station of line" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "stations/block/improve-as-first-station", :record => :new_episodes do
        line = CF::Line.new("Digitd", "Digitization")
        station = CF::Station.new({:type => "improve"}) 
        expect { line.stations station }.to raise_error(CF::ImproveStationNotAllowed)
      end
    end
    
    it "should only display the attributes which are mentioned in to_s method" do
      VCR.use_cassette "stations/block/display-to_s", :record => :new_episodes do
      # WebMock.allow_net_connect!
        line = CF::Line.create("Display_station", "Digitization") do
          CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line => self, :type => "work"}) do |station|
            CF::HumanWorker.new({:station => station, :number => 2, :reward => 20})
          end
        end
        line.stations.first.to_s.should eql("{:type => WorkStation, :index => 1, :line_title => Display_station, :station_input_formats => , :errors => }")
      end
    end
    
    it "should only display the attributes which are mentioned in to_s method for tournament station" do
      VCR.use_cassette "stations/block/display-to_s-tournament", :record => :new_episodes do
      # WebMock.allow_net_connect!
        line = CF::Line.create("Display_station_tournament", "Digitization") do
          CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line => self, :type => "tournament", :jury_worker=> {:max_judges => 10, :reward => 5}, :auto_judge => {:enabled => true}}) do |s|
            CF::HumanWorker.new({:station => s, :number => 2, :reward => 20})
          end
        end
        line.stations.first.to_s.should eql("{:type => TournamentStation, :index => 1, :line_title => Display_station_tournament, :station_input_formats => , :jury_worker => {:max_judges=>10, :reward=>5}, auto_judge => {:enabled=>true}, :errors => }")
      end
    end
  end

  context "get station" do
    it "should get information about a single station" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "stations/plain-ruby/get-station", :record => :new_episodes do
        line = CF::Line.new("Digitizerd1","Digitization")
        line.title.should eq("Digitizerd1")
        station = CF::Station.new(:type => "Work")
        line.stations station
        station.type.should eq("Work")
        line.stations.first.get.type.should eq("WorkStation")
      end
    end

    it "should get all existing stations of a line" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "stations/plain-ruby/get-all-stations", :record => :new_episodes do
        line = CF::Line.new("Digitizrd11","Digitization")
        line.title.should eq("Digitizrd11")
        station = CF::Station.new(:type => "Work")
        line.stations station
        stations = CF::Station.all(line)
        stations[0].type.should eq("WorkStation")
      end
    end
  end
  
  context "create multiple station" do
    xit "should create two stations with improve station" do
      WebMock.allow_net_connect!
      # VCR.use_cassette "stations/block/multiple-station", :record => :new_episodes do
      line = CF::Line.create("Company Info -1","Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
        CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
        CF::Station.create({:line => l, :type => "work"}) do |s|
          CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => s, :title => "Enter the name of CEO", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
            CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
            CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
          end
        end
      end

      station = CF::Station.new({:type => "Improve"})
      line.stations station

      worker = CF::HumanWorker.new({:number => 1, :reward => 10})
      line.stations.last.worker = worker

      form = CF::TaskForm.new({:title => "Enter the address of the given Person", :instruction => "Description"})
      line.stations.last.form = form

      form_fields_1 = CF::FormField.new({:label => "Street", :field_type => "SA", :required => "true"})
      line.stations.last.form.form_fields form_fields_1
      form_fields_2 = CF::FormField.new({:label => "City", :field_type => "SA", :required => "true"})
      line.stations.last.form.form_fields form_fields_2
      form_fields_3 = CF::FormField.new({:label => "Country", :field_type => "SA", :required => "true"})
      line.stations.last.form.form_fields form_fields_3

      run = CF::Run.create(line,"Creation of Multiple Station", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
      # debugger
      result_of_station_1 = run.output(:station => 1)
      result_of_station_2 = run.output(:station => 2)
      @final_output = run.final_output
      @final_output.first.meta_data['company'].should eql("Apple")
      @final_output.first.final_outputs.last['street'].should eql("Kupondole")
      @final_output.first.final_outputs.last['city'].should eql("Kathmandu")
      @final_output.first.final_outputs.last['country'].should eql("Nepal")
      # end
    end
  end

  context "create multiple station" do
    it "should create two stations using different input format" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "stations/block/multiple-station-adding-input-format", :record => :new_episodes do
        line = CF::Line.create("Company-info-214","Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
          CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
          CF::Station.create({:line => l, :type => "work", :input_formats=> {:station_0 => [{:name => "Company"},{:name => "Website", :except => true}]}}) do |s|
            CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
            CF::TaskForm.create({:station => s, :title => "Enter the name of CEO", :instruction => "Describe"}) do |i|
              CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end

        station = CF::Station.new(
        {:type => "work", :input_formats => {:station_0 => [{:name => "Website"}], :station_1 => [{:name => "Last Name", :except => true}]}})
        line.stations station

        worker = CF::HumanWorker.new({:number => 1, :reward => 10})
        line.stations.last.worker = worker

        form = CF::TaskForm.new({:title => "Enter the address of the given Person", :instruction => "Description"})
        line.stations.last.form = form

        form_fields_1 = CF::FormField.new({:label => "Street", :field_type => "SA", :required => "true"})
        line.stations.last.form.form_fields form_fields_1
        form_fields_2 = CF::FormField.new({:label => "City", :field_type => "SA", :required => "true"})
        line.stations.last.form.form_fields form_fields_2
        form_fields_3 = CF::FormField.new({:label => "Country", :field_type => "SA", :required => "true"})
        line.stations.last.form.form_fields form_fields_3
        station_1 = line.stations.first.get
        station_1.input_formats.count.should eql(1)
        station_1.input_formats.first.name.should eql("Company")
        station_1.input_formats.first.required.should eql(true)
        station_1.input_formats.first.valid_type.should eql("general")
        station_2 = line.stations.last.get
        station_2.input_formats.count.should eql(3)
        station_2.input_formats.map(&:name).should include("Website")
        station_2.input_formats.map(&:name).should include("First Name")
        station_2.input_formats.map(&:name).should include("Middle Name")
        station_2.input_formats.map(&:required).should include(true)
        station_2.input_formats.map(&:required).should include(false) #how to make it true
        station_2.input_formats.map(&:required).should include(false)
        station_2.input_formats.map(&:valid_type).should include("url")
        station_2.input_formats.map(&:valid_type).should include("general")
        station_2.input_formats.map(&:valid_type).should include("general")
      end
    end
  end

  context "create a station with errors" do
    it "in plain ruby way and it should display an error message" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "stations/plain-ruby/create-without-type", :record => :new_episodes do
        line = CF::Line.new("Digitize--ard", "Digitization")
        station = CF::Station.new()
        line.stations station
        line.stations.first.errors.should eql("The Station type  is invalid.")
      end
    end
    
    it "in block DSL way and it should display an error message" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "stations/block/create-without-type", :record => :new_episodes do
        line = CF::Line.create("Digitize--ard1", "Digitization") do |l|
          CF::Station.new({:line => l})
        end
        line.stations.first.errors.should eql("The Station type  is invalid.")
      end
    end
    
    it "in block DSL way without creating input_format it should display an error message" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "stations/block/create-without-input_type_error", :record => :new_episodes do
        line = CF::Line.create("Digitize--ard2", "Digitization") do |l|
          CF::Station.new({:line => l, :type => "work"})
        end
        line.stations.first.errors.should eql("Input formats not assigned for the line #{line.title.downcase}")
      end
    end
    
    it "Tournament station displaying errors due to invalid settings" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "stations/block/tournament-station-error", :record => :new_episodes do
        line = CF::Line.create("Digitized-91", "Digitization") do
          CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.new({:line => self, :type => "tournament"})
        end
        line.stations.first.type.should eq("Tournament")
        line.stations.first.errors.should eql("[\"Jury worker can't be blank\"]")
      end
    end
  end
end