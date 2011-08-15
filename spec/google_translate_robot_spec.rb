# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::RobotWorker do
    context "create a google translator worker" do
      it "should create google_translate_robot worker for first station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "robot_worker/google_translate_robot/plain-ruby/create-worker-in-first-station", :record => :new_episodes do
          line = CF::Line.new("google_translate_robot","Digitization")
          input_format = CF::InputFormat.new({:name => "text", :required => true, :valid_type => "general"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::RobotWorker.create({:type => "google_translate_robot", :settings => {:data => ["{{text}}"], :from => "en", :to => "es"}})
          line.stations.first.worker = worker

          form = CF::TaskForm.new({:title => "Enter text", :instruction => "Describe"})
          line.stations.first.form = form

          line.title.should eql("google_translate_robot")
          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:data => ["{{text}}"], :from => "en", :to => "es"})
          line.stations.first.worker.type.should eql("GoogleTranslateRobot")
          run = CF::Run.create(line, "google_translate_robot_run", [{"text"=> "I started loving Monsoon"}])
          @final_output = run.final_output
          line.stations.first.worker.number.should eq(1)
          @final_output.first.final_output.first.translation_of_text.should eql('Empecé a amar a Monzón')
        end
      end
      
      it "should create google_translate_robot in block DSL way" do
        VCR.use_cassette "robot_worker/google_translate_robot/block/create-worker-block-dsl-way", :record => :new_episodes do
        # WebMock.allow_net_connect!
          line = CF::Line.create("google_translate_robot_1","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "text", :required => true, :valid_type => "general"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :type => "google_translate_robot", :settings => {:data => ["{{text}}"], :from => "en", :to => "es"}})
            end
          end
          line.title.should eql("google_translate_robot_1")
          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:data => ["{{text}}"], :from => "en", :to => "es"})
          line.stations.first.worker.type.should eql("GoogleTranslateRobot")
          run = CF::Run.create(line, "google_translate_robot_run_1", [{"text"=> "I started loving Monsoon"}])

          @final_output = run.final_output
          line.stations.first.worker.number.should eq(1)
          @final_output.first.final_output.first.translation_of_text.should eql('Empecé a amar a Monzón')
        end
      end
    end
  end
end