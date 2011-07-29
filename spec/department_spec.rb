require 'spec_helper'

describe CF::Department do
  context "return category" do
    it "should get all the departments" do
      VCR.use_cassette "department/all", :record => :new_episodes do
        departments = CF::Department.all
        departments.map(&:name).should include("Digitization")
        departments.map(&:name).should include("Data Processing")
        departments.map(&:name).should include("Survey")
      end
    end
  end
  
  context "return lines of a category" do
    xit "should return all the lines of a particular category" do
      # => Departments are searched by their id .......
      
      WebMock.allow_net_connect!
      # VCR.use_cassette "department/lines-of-category", :record => :new_episodes do
        5.times do |i|
          CF::Line.new("Digitizeard-#{i}","Digitization")
        end
        5.times do |i|
          CF::Line.new("Linename-#{i}","Survey")
        end
        lines_category_1 = CF::Department.get_lines_of_department("Digitization")
        lines_category_2 = CF::Department.get_lines_of_department("Survey")
        debugger
        lines_category_1.map(&:name).should include("digitizeard-3")
      # end
    end
  end
end
