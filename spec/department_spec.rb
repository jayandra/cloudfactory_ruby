require 'spec_helper'

describe "CloudFactory::Category" do
  context "return category" do
    it "should get all the departments" do
      VCR.use_cassette "department/all", :record => :new_episodes do
        departments = CloudFactory::Department.all
        departments.map(&:name).should include("Digitization")
        departments.map(&:name).should include("Data Processing")
        departments.map(&:name).should include("Survey")
      end
    end
  end
  
  context "return lines of a category" do
    xit "should return all the lines of a particular category" do
      VCR.use_cassette "department/lines-of-category", :record => :new_episodes do
        5.times do |i|
          CloudFactory::Line.new("Digitize Card #{i}","4dc8ad6572f8be0600000001")
        end
        5.times do |i|
          CloudFactory::Line.new("Line Name #{i}","4dc8ad6572f8be0600000006")
        end
        lines_category_1 = CloudFactory::Department.get_lines_of_department("4dc8ad6572f8be0600000001")
        lines_category_2 = CloudFactory::Department.get_lines_of_department("4dc8ad6572f8be0600000006")
        debugger
        lines_category_1.map(&:name).should include("digitize-card-3")
      end
    end
  end
end
