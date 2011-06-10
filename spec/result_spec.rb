require 'spec_helper'

module CF
  describe CF::Result do
    context "Trace result" do
      it "should trace the result of a production run" do
        VCR.use_cassette "result/block/create-run", :record => :new_episodes do
          line = CF::Line.create("Digitize Card","Digitization") do |l|
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::InputHeader.new({:station => s, :label => "Company",:field_type => "text_data",:value => "Google", :required => true, :validation_format => "general"})
              CF::InputHeader.new({:station => s, :label => "Website",:field_type => "text_data",:value => "www.google.com", :required => true, :validation_format => "url"})
              CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CF::Form.create({:station => s, :title => "Enter the names of CEO", :description => "Enter the full name of CEO of the following company"}) do |i|
                CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
                CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
                CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
              end
            end
          end

          run = CF::Run.create(line, "Run for result tracing", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          run_id = run.id
          
          # debugger
          got_result = CF::Result.get_result(run_id)
          got_result.class.should eql(Array)
          got_result.size.should eql(3)
          got_result.first.class.should eql(CF::Result)
          got_result[2].results.last['first-name'].should eql("Larry")
          got_result[2].results.last['last-name'].should eql("Paige")
          got_result[1].results.last['first-name'].should eql("Mark")
          got_result[1].results.last['last-name'].should eql("Zuckerberg")
          got_result[0].results.last['first-name'].should eql("Bob")
          got_result[0].results.last['last-name'].should eql("Marley")
        end
      end
    end
  end
end