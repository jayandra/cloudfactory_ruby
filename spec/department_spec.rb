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
end
