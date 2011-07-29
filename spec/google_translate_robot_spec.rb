# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::GoogleTranslateRobot do
    context "create a google translator worker" do
      it "should create google_translate_robot worker for first station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "google_translate_robot/block/create-worker-in-first-station", :record => :new_episodes do
          line = CF::Line.new("Digitize3001","Digitization")
          input_format = CF::InputFormat.new({:name => "text", :required => true, :valid_type => "general"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::GoogleTranslateRobot.create({:station => line.stations.first, :data => ["{text}"], :from => "en", :to => "es"})

          form = CF::TaskForm.new({:title => "Enter text", :instruction => "Describe"})
          line.stations.first.form = form

          form_fields = CF::FormField.new({:label => "Description", :field_type => "SA", :required => "true"})
          line.stations.first.form.form_fields form_fields
          line.title.should eql("Digitize3001")
          line.stations.first.worker.class.should eql(CF::GoogleTranslateRobot)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.from.should eql("en")
          line.stations.first.worker.to.should eql("es")
          line.stations.first.worker.data.should eql(["{text}"])
          run = CF::Run.create(line, "google_translate_robot", [{"text"=> "I started loving Monsoon", "meta_data_text"=>"monsoon"}])

          @final_output = run.final_output
          line.stations.first.worker.number.should eq(1)
          @final_output.first.final_output.first.translation_of_text.should eql('Empecé a amar a Monzón')
        end
      end
      
      it "should create google_translate_robot worker for first station in a plain ruby way without passing station parameter within the syntax" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "google_translate_robot/plain/create-worker-in-plain-ruby-way", :record => :new_episodes do
          line = CF::Line.new("Digitize-rd1-3004","Digitization")
          input_format = CF::InputFormat.new({:name => "text", :required => true, :valid_type => "general"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::GoogleTranslateRobot.create({ :data => ["{text}"], :from => "en", :to => "es"})
          line.stations.first.worker = worker
          
          form = CF::TaskForm.new({:title => "Enter text", :instruction => "Describe"})
          line.stations.first.form = form

          form_fields = CF::FormField.new({:label => "Description", :field_type => "SA", :required => "true"})
          line.stations.first.form.form_fields form_fields

          line.stations.first.form.form_fields form_fields
          line.title.should eql("Digitize-rd1-3004")
          line.stations.first.worker.class.should eql(CF::GoogleTranslateRobot)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.from.should eql("en")
          line.stations.first.worker.to.should eql("es")
          line.stations.first.worker.data.should eql(["{text}"])
          run = CF::Run.create(line, "googletranslaterobot11", [{"text"=> "I started loving Monsoon", "meta_data_text"=>"monsoon"}])

          @final_output = run.final_output
          line.stations.first.worker.number.should eq(1)
          @final_output.first.final_output.first.translation_of_text.should eql('Empecé a amar a Monzón')
        end
      end
      
      it "should create google_translate_robot worker for multiple station in a plain ruby way" do
        VCR.use_cassette "google_translate_robot/block/create-worker-multiple-station", :record => :new_episodes do
          line = CF::Line.create("Googleranslateobot-111","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
            CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
              CF::TaskForm.create({:station => s, :title => "Enter about the CEO", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
                CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
                CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
                CF::FormField.new({:form => i, :label => "ceo", :field_type => "LA", :required => "true"})
              end
            end
          end
          
          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::GoogleTranslateRobot.create({:station => line.stations.last, :data => ["{ceo}"], :from => "en", :to => "es"})

          run = CF::Run.create(line, "googleranslateobotorompany-111", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
          # debugger
          @final_output = run.final_output
          line.stations.last.worker.number.should eq(1)
          @final_output.first.final_output.first.translation_of_ceo.should eql("Él es la persona que crean puestos de trabajo para otros")
        end
      end
      
      it "should create google_translate_robot in block DSL way" do
        VCR.use_cassette "google_translate_robot/block/create-worker-block-dsl-way", :record => :new_episodes do
        # WebMock.allow_net_connect!
          line = CF::Line.create("Google-translate-robot11","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "text", :required => true, :valid_type => "general"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::GoogleTranslateRobot.create({:station => s, :data => ["{text}"], :from => "en", :to => "es"})
              CF::TaskForm.create({:station => s, :title => "Enter text", :instruction => "Describe"}) do |i|
                CF::FormField.new({:form => i, :label => "Description", :field_type => "SA", :required => "true"})
              end
            end
          end
          line.title.should eql("Google-translate-robot11")
          line.stations.first.worker.class.should eql(CF::GoogleTranslateRobot)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.from.should eql("en")
          line.stations.first.worker.to.should eql("es")
          line.stations.first.worker.data.should eql(["{text}"])
          run = CF::Run.create(line, "googletranslaterobot12", [{"text"=> "I started loving Monsoon", "meta_data_text"=>"monsoon"}])

          @final_output = run.final_output
          line.stations.first.worker.number.should eq(1)
          @final_output.first.final_output.first.translation_of_text.should eql('Empecé a amar a Monzón')
        end
      end
    end
  end
end