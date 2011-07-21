# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::EntityExtractionRobot do
    context "create a entity extraction robot worker" do
      it "should create entity extraction robot worker for first station in Block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "entity_extraction_robot/block/create-worker-single-station", :record => :new_episodes do
          line = CF::Line.create("entity_extraction_robot-1","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "text", :valid_type => "general", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::EntityExtractionRobot.create({:station => s, :document => ["Franz Kafka and George Orwell are authors. Ludwig Von Beethoven and Mozart are musicians. China and Japan are countries"]})
            end
          end
          run = CF::Run.create(line, "entity_extraction_robot_run-1", [{"text"=> "Franz Kafka and George Orwell are authors. Ludwig Von Beethoven and Mozart are musicians. China and Japan are countries"}])
          output = run.final_output
          output.first.final_output.first.entity_counts_of_document.should eql([["2", "2", "1", "1", "2", "1"]])
          output.first.final_output.first.entity_names_of_document.should eql([["Ludwig Von Beethoven", "Franz Kafka", "George Orwell", "Mozart", "China", "Japan"]])
          output.first.final_output.first.entity_relevances_of_document.should eql([[92.12089999999999, 73.8997, 48.079100000000004, 28.9416, 27.1982, 21.1997]])
          output.first.final_output.first.entity_types_of_document.should eql([["Person", "Person", "Person", "Person", "Country", "Country"]])
          line.stations.first.worker.class.should eql(CF::EntityExtractionRobot)
          line.stations.first.worker.reward.should eql(5)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.document.should eql(["Franz Kafka and George Orwell are authors. Ludwig Von Beethoven and Mozart are musicians. China and Japan are countries"])
        end
      end

      it "should create entity extraction robot worker for first station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "entity_extraction_robot/plain/create-worker-in-first-station", :record => :new_episodes do
          line = CF::Line.new("entity_extraction_robot-2","Digitization")
          input_format = CF::InputFormat.new({:name => "text", :required => "true", :valid_type => "general"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::EntityExtractionRobot.create({:document => ["Franz Kafka and George Orwell are authors. Ludwig Von Beethoven and Mozart are musicians. China and Japan are countries"]})
          line.stations.first.worker = worker

          run = CF::Run.create(line, "entity_extraction_robot_run-2", [{"text"=> "Franz Kafka and George Orwell are authors. Ludwig Von Beethoven and Mozart are musicians. China and Japan are countries"}])
          output = run.final_output
          output.first.final_output.first.entity_counts_of_document.should eql([["2", "2", "1", "1", "2", "1"]])
          output.first.final_output.first.entity_names_of_document.should eql([["Ludwig Von Beethoven", "Franz Kafka", "George Orwell", "Mozart", "China", "Japan"]])
          output.first.final_output.first.entity_relevances_of_document.should eql([[92.12089999999999, 73.8997, 48.079100000000004, 28.9416, 27.1982, 21.1997]])
          output.first.final_output.first.entity_types_of_document.should eql([["Person", "Person", "Person", "Person", "Country", "Country"]])
          line.stations.first.worker.class.should eql(CF::EntityExtractionRobot)
          line.stations.first.worker.reward.should eql(5)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.document.should eql(["Franz Kafka and George Orwell are authors. Ludwig Von Beethoven and Mozart are musicians. China and Japan are countries"])
        end
      end
    end
  end
end