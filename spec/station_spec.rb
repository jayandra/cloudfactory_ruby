require 'spec_helper'

describe CF::Station do
  context "create a station" do
    it "the plain ruby way" do
      VCR.use_cassette "stations/plain-ruby/create", :record => :new_episodes do
        line = CF::Line.new("Digitize Card", "Digitization")
        station = CF::Station.new({:type => "work"})
        line.stations station
        line.stations.first.type.should eql("WorkStation")
      end
    end

    it "using the block variable" do
      VCR.use_cassette "stations/block/create-with-block-var", :record => :new_episodes do
        line = CF::Line.create("Digitize Card", "Digitization") do
          CF::Station.create({:line => self, :type => "work"}) do |s|
            CF::HumanWorker.new({:station => s, :number => 2, :reward => 20})
            CF::Form.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
              CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.stations.first.type.should eq("WorkStation")
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
            CF::Form.create({:station => self, :title => "Enter text from a business card image", :description => "Describe"}) do
              CF::FormField.new({:instruction => self, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:instruction => self, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:instruction => self, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.stations.first.type.should eq("WorkStation")
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
            CF::Form.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
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
    
    it "should create a station of Improve station" do
      VCR.use_cassette "stations/block/improve-station", :record => :new_episodes do
        line = CF::Line.create("Digitize Card", "Digitization") do
          CF::Station.create({:line => self, :type => "improve"}) do |s|
            CF::HumanWorker.new({:station => s, :number => 2, :reward => 10})
            CF::Form.create({:station => s, :title => "Enter text from following business card image", :description => "title is description"}) do |i|
              CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.stations.first.type.should eq("ImproveStation")
        line.stations.first.worker.number.should eql(2)
        line.stations.first.worker.reward.should eql(10)
        line.stations.first.instruction.title.should eq("Enter text from following business card image")
        line.stations.first.instruction.description.should eq("title is description")
        line.stations.first.instruction.form_fields[0].label.should eq("First Name")
        line.stations.first.instruction.form_fields[1].label.should eq("Middle Name")
        line.stations.first.instruction.form_fields[2].label.should eq("Last Name")
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
        line.stations.first.get.type.should eq("WorkStation")
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

end