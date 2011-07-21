# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::TextAppendingRobot do
    context "create a sentiment robot worker" do
      xit "should create content_scraping_robot worker for first station in Block DSL way" do
        WebMock.allow_net_connect!
        # VCR.use_cassette "term_extraction/block/create-worker-single-station", :record => :new_episodes do
          line = CF::Line.create("text_appending_robot_3", "Digitization") do
            CF::InputFormat.new({:line => self,:name => "Description", :required => true, :valid_type => "general"})
            # CF::InputFormat.new({:line => self,:name => "Country", :required => true, :valid_type => "general"})
            # CF::Station.create({:line => self, :type => "work"}) do |station|
            #               CF::HumanWorker.new({:station => station, :number => 1, :reward => 20})
            #               CF::TaskForm.create({:station => station, :title => "Write your view about given Companies", :instruction => "Describe"}) do |i|
            #                 CF::FormField.new({:form => i, :label => "description", :field_type => "SA", :required => "true"})
            #               end
            #             end
            CF::Station.create({:line => self, :type => "work"}) do |s1|
              CF::TextAppendingRobot.create({:station => s1, :append => ["this is Cloudfactory", "it will blow your mind off"], :separator => "||"})
            end
          end
          run = CF::Run.create(line, "text_appending_robot_run_10", [{"Description" => "this is Cloudfactory"}, {"Description" => "it will blow your mind off"}])
          debugger
          output = run.final_output
          station_1_output = run.output(:station => 1)
          debugger
          # output.first.final_output.first.keyword_relevance_url.should eql([99.7991, 95.6566, 83.2383, 79.39450000000001, 76.0281])
          #           output.first.final_output.first.keywords_url.should eql(["Web App", "web application", "Web App Development", "Web App Management", "world-class web development"])
          #           output.first.final_output.first.max_retrieve.should eql("5")
          #           output.first.final_output.first.show_source_text.should eql("true")
                    line.stations.last.worker.class.should eql(CF::TextAppendingRobot)
          #           line.stations.first.worker.reward.should eql(8)
          #           line.stations.first.worker.number.should eql(1)
          #           line.stations.first.worker.url.should eql(["{url}"])
          #           line.stations.first.worker.max_retrieve.should eql(5)
          #           line.stations.first.worker.show_source_text.should eql(true)
        # end
      end

      xit "should create content_scraping_robot worker for first station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "term_extraction/plain/create-worker-in-first-station", :record => :new_episodes do
          line = CF::Line.new("term_extraction_7","Digitization")
          input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::TermExtraction.create({:url => ["{url}"], :max_retrieve => 5, :show_source_text => true})
          line.stations.first.worker = worker

          run = CF::Run.create(line, "term_extraction_run_7", [{"url"=> "http://www.sprout-technology.com"}])
          output = run.final_output
          output.first.final_output.first.keyword_relevance_url.should eql([99.7991, 95.6566, 83.2383, 79.39450000000001, 76.0281])
          output.first.final_output.first.keywords_url.should eql(["Web App", "web application", "Web App Development", "Web App Management", "world-class web development"])
          output.first.final_output.first.max_retrieve.should eql("5")
          output.first.final_output.first.show_source_text.should eql("true")
          line.stations.first.worker.class.should eql(CF::TermExtraction)
          line.stations.first.worker.reward.should eql(8)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.url.should eql(["{url}"])
          line.stations.first.worker.max_retrieve.should eql(5)
          line.stations.first.worker.show_source_text.should eql(true)
        end
      end
    end
  end
end