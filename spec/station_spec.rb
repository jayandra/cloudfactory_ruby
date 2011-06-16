require 'spec_helper'

describe CF::Station do
  context "create a station" do
    it "the plain ruby way" do
      VCR.use_cassette "stations/plain-ruby/create", :record => :new_episodes do
        line = CF::Line.new("Digitize Card", "Digitization")
        station = CF::Station.new({:type => "work"})
        line.stations station
        line.stations.first.type.should eql("Work")
      end
    end

    it "using the block variable" do
      VCR.use_cassette "stations/block/create-with-block-var", :record => :new_episodes do
        line = CF::Line.create("Digitize Card", "Digitization") do
          CF::Station.create({:line => self, :type => "work"}) do |s|
            CF::HumanWorker.new({:station => s, :number => 2, :reward => 20})
            CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
              CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.stations.first.type.should eq("Work")
        line.stations.first.worker.number.should eql(2)
        line.stations.first.worker.reward.should eql(20)
        line.stations.first.instruction.title.should eq("Enter text from a business card image")
        line.stations.first.instruction.description.should eq("Describe")
        line.stations.first.instruction.form_fields[0].label.should eq("First Name")
        line.stations.first.instruction.form_fields[1].label.should eq("Middle Name")
        line.stations.first.instruction.form_fields[2].label.should eq("Last Name")
      end
    end

    it "using without the block variable also creating instruction without block variable" do
      VCR.use_cassette "stations/block/create-without-block-var", :record => :new_episodes do
        line = CF::Line.create("Digitize Card", "Digitization") do
          CF::Station.create({:line => self, :type => "work"}) do
            CF::HumanWorker.new({:station => self, :number => 2, :reward => 20})
            CF::TaskForm.create({:station => self, :title => "Enter text from a business card image", :description => "Describe"}) do
              CF::FormField.new({:instruction => self, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:instruction => self, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:instruction => self, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
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

    it "should create a station of Tournament station" do
      VCR.use_cassette "stations/block/tournament-station", :record => :new_episodes do
        line = CF::Line.create("Digitize Card", "Digitization") do
          CF::Station.create({:line => self, :type => "tournament", :max_judges => 10, :auto_judge => true}) do |s|
            CF::HumanWorker.new({:station => s, :number => 3, :reward => 20})
            CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
              CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.stations.first.type.should eq("Tournament")
        line.stations.first.worker.number.should eql(3)
        line.stations.first.worker.reward.should eql(20)
        line.stations.first.instruction.title.should eq("Enter text from a business card image")
        line.stations.first.instruction.description.should eq("Describe")
        line.stations.first.instruction.form_fields[0].label.should eq("First Name")
        line.stations.first.instruction.form_fields[1].label.should eq("Middle Name")
        line.stations.first.instruction.form_fields[2].label.should eq("Last Name")
      end
    end
    
    it "should create a station of Improve station as first station of line" do
      VCR.use_cassette "stations/block/improve-as-first-station", :record => :new_episodes do
        line = CF::Line.new("Digitize Card", "Digitization")
        station = CF::Station.new({:type => "improve"}) 
        expect { line.stations station }.to raise_error(CF::ImproveStationNotAllowed)
      end
    end
  end

  context "get station" do
    it "should get information about a single station" do
      VCR.use_cassette "stations/plain-ruby/get-station", :record => :new_episodes do
        line = CF::Line.new("Digitize Card","Digitization")
        line.title.should eq("Digitize Card")
        station = CF::Station.new(:type => "Work")
        line.stations station
        station.type.should eq("Work")
        line.stations.first.get.type.should eq("Work")
      end
    end

    it "should get all existing stations of a line" do
      VCR.use_cassette "stations/plain-ruby/get-all-stations", :record => :new_episodes do
        line = CF::Line.new("Digitize Card","Digitization")
        line.title.should eq("Digitize Card")
        station = CF::Station.new(:type => "Work")
        line.stations station
        stations = CF::Station.all(line)
        stations[0]._type.should eq("WorkStation")
      end
    end
  end

  context "deleting a station" do
    it "should delete a station" do
      VCR.use_cassette "stations/plain-ruby/delete", :record => :new_episodes do
        line = CF::Line.new("Digitize Card","Digitization")
        line.title.should eq("Digitize Card")
        station = CF::Station.new(:type => "Work")
        line.stations station
        line.stations.first.delete
        deleted_station = line.stations.first.get
        deleted_station.message.should eql("Resource not found.")
        deleted_station.code.should eql(404)
      end
    end
  end

  context "create multiple station" do
    it "should create two stations with improve station" do
      VCR.use_cassette "stations/block/multiple-station", :record => :new_episodes do
        line = CF::Line.create("Company Info -1","Digitization") do |l|
          CF::InputHeader.new({:line => l, :label => "Company",:field_type => "text_data",:value => "Google", :required => true, :validation_format => "general"})
          CF::InputHeader.new({:line => l, :label => "Website",:field_type => "text_data",:value => "www.google.com", :required => true, :validation_format => "url"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
            CF::TaskForm.create({:station => s, :title => "Enter the name of CEO", :description => "Describe"}) do |i|
              CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        
        station = CF::Station.new({:type => "Improve"})
        line.stations station
        
        worker = CF::HumanWorker.new({:number => 2, :reward => 10})
        line.stations.last.worker = worker

        form = CF::TaskForm.new({:title => "Enter the address of the following Person", :description => "Description"})
        line.stations.last.instruction = form

        form_fields_1 = CF::FormField.new({:label => "Street", :field_type => "SA", :required => "true"})
        line.stations.last.instruction.form_fields form_fields_1
        form_fields_2 = CF::FormField.new({:label => "City", :field_type => "SA", :required => "true"})
        line.stations.last.instruction.form_fields form_fields_2
        form_fields_3 = CF::FormField.new({:label => "Country", :field_type => "SA", :required => "true"})
        line.stations.last.instruction.form_fields form_fields_3

        # run = CF::Run.create(line,"Creation of Multiple Station", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))

      end
    end
  end
end