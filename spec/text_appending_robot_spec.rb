# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::TextAppendingRobot do
    context "create a text appending robot worker" do
      it "should create text appending robot worker for first station in Block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "text_appending_robot/block/create-worker-single-station", :record => :new_episodes do
          html =   '<textarea name = "output[description][]"></textarea>
          <textarea name = "output[description][]"></textarea>
          <textarea name = "output[description][]"></textarea>
          <textarea name = "output[description][]"></textarea>'

          line = CF::Line.create("text_appending_robot_30", "Digitization") do
            CF::InputFormat.new({:line => self,:name => "Company", :required => true, :valid_type => "general"})
            CF::InputFormat.new({:line => self,:name => "Website", :required => true, :valid_type => "url"})
            CF::Station.create({:line => self, :type => "work"}) do |s|
              CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CF::CustomTaskForm.create({:station => s, :title => "Descibe about given Company", :instruction => "Describe", :raw_html => html})
            end
            CF::Station.create({:line => self, :type => "work"}) do |s1|
              CF::TextAppendingRobot.create({:station => s1, :append => ["{description}"], :separator => "||"})
            end
          end
          run = CF::Run.create(line, "text_appending_robot_run_19", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          # debugger
          output = run.final_output
          station_1_output = run.output(:station => 1)
          station_1_output['description'].should eql(["this is description", "about company", "the company works on", "Ruby on Rails"])
          output.first.final_output.first.append_description.should eql("this is description||about company||the company works on||Ruby on Rails")
          line.stations.last.worker.class.should eql(CF::TextAppendingRobot)
          line.stations.first.worker.reward.should eql(20)
          line.stations.first.worker.number.should eql(1)
          line.stations.last.worker.append.should eql(["{description}"])
          line.stations.last.worker.separator.should eql("||")
        end
      end

      it "should create content_scraping_robot worker for first station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "text_appending_robot/plain/create-worker-in-first-station", :record => :new_episodes do
          html =   '<textarea name = "output[description][]"></textarea>
          <textarea name = "output[description][]"></textarea>
          <textarea name = "output[description][]"></textarea>
          <textarea name = "output[description][]"></textarea>'
          
          line = CF::Line.new("term_extraction_25","Digitization")
          input_format = CF::InputFormat.new({:name => "Company", :required => true, :valid_type => "general"})
          input_format_1 = CF::InputFormat.new({:name => "Website", :required => true, :valid_type => "url"})
          line.input_formats input_format
          line.input_formats input_format_1

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::HumanWorker.new({:number => 1, :reward => 20})
          line.stations.first.worker = worker
          
          form = CF::CustomTaskForm.create({:title => "Descibe about given Company", :instruction => "Describe", :raw_html => html})
          line.stations.first.form = form

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker_1 = CF::TextAppendingRobot.create({:append => ["{description}"], :separator => "||"})
          line.stations.last.worker = worker_1
          
          run = CF::Run.create(line, "text_appending_robot_run_25", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          # debugger
          output = run.final_output
          station_1_output = run.output(:station => 1)
          station_1_output['description'].should eql(["this is description", "about company", "the company works on", "Ruby on Rails"])
          output.first.final_output.first.append_description.should eql("this is description||about company||the company works on||Ruby on Rails")
          line.stations.last.worker.class.should eql(CF::TextAppendingRobot)
          line.stations.first.worker.reward.should eql(20)
          line.stations.first.worker.number.should eql(1)
          line.stations.last.worker.append.should eql(["{description}"])
          line.stations.last.worker.separator.should eql("||")
        end
      end
    end
  end
end