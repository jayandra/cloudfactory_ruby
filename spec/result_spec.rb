require 'spec_helper'

module CloudFactory
  describe CloudFactory::Result do
    context "Trace result" do
      it "should trace the result of a production run" do
        VCR.use_cassette "result/block/create-run", :record => :new_episodes do
          line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
            CloudFactory::Station.create({:line => l, :type => "work"}) do |s|
              CloudFactory::InputHeader.new({:station => s, :label => "Company",:field_type => "text_data",:value => "Google", :required => true, :validation_format => "general"})
              CloudFactory::InputHeader.new({:station => s, :label => "Website",:field_type => "text_data",:value => "www.google.com", :required => true, :validation_format => "url"})
              CloudFactory::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CloudFactory::Form.create({:station => s, :title => "Enter name of CEO", :description => "Enter the full name of CEO of the following company"}) do |i|
                CloudFactory::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
                CloudFactory::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
                CloudFactory::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
              end
            end
          end

          run = CloudFactory::Run.create(line, "Run for result tracing", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          run_id = run.id

          got_result = CloudFactory::Result.get_result(run_id)
          debugger
          got_result.class.should eql(Array)
          got_result.size.should eql(3)
          got_result.first.class.should eql(CloudFactory::Result)
          got_result.last.results.last['first-name'].should eql("Larry")
          got_result.last.results.last['last-name'].should eql("Paige")
        end
      end
    end
  end
end