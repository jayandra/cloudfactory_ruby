require 'spec_helper'

describe CloudFactory::Station do
  context "create a station" do
    it "the plain ruby way" do
      station = CloudFactory::Station.new("Station One")
      station.name.should eq("Station One")
    end

    it "using the block variable" do
      form_fields = []
      form_fields << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
      form_fields << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
      form_fields << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")
      
      worker = CloudFactory::HumanWorker.new(2, 0.2)
      station = CloudFactory::Station.create("Station 1 Name") do |s|
        s.worker = worker
        s.instruction = CloudFactory::StandardInstruction.create(:title => "Enter text from a business card image", :description => "Describe") do |i|
          i.form_fields = form_fields
        end
      end
      station.name.should eq("Station 1 Name")
      station.worker.should == worker
      station.worker.number.should == 2
      station.worker.reward.should == 0.2
    end

    it "using without the block variable also creating instruction without block variable" do
      form_fields = []
      form_fields << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
      form_fields << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
      form_fields << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")
      
      human_worker = CloudFactory::HumanWorker.new(2, 0.2)
      station_1 = CloudFactory::Station.create("Station 1 Name") do 
        worker human_worker
        instruction = CloudFactory::StandardInstruction.create(:title => "Enter text from a business card image", :description => "Describe") do 
          form_fields form_fields
        end 
      end
      station_1.name.should eq("Station 1 Name")
      station_1.worker.should == human_worker
      station_1.worker.number.should == 2
      station_1.worker.reward.should == 0.2
    end
  end
end