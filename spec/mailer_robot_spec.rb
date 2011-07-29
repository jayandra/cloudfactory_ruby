# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::MailerRobot do
    context "create a mailer robot worker" do
      it "should create mailer robot worker for first station in Block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "mailer_robot/block/create-worker-single-station", :record => :new_episodes do
          @template = "<html><body><h1>Hello {{user}} Welcome to CLoudfactory!!!!</h1><p>Thanks for using!!!!</p></body></html>"
          line = CF::Line.create("mailer_robot_3","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "to", :valid_type => "general", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::MailerRobot.create({:station => s, :to => ["manish.das@sprout-technology.com"], :template => @template, :template_variables => {"user" =>"Manish"}})
            end
          end
          run = CF::Run.create(line, "mailer_robot__run_3", [{"to"=> "manish.das@sprout-technology.com"}])
          output = run.final_output
          output.first.final_output.first.recipients_of_to.should eql(["manish.das@sprout-technology.com"])
          output.first.final_output.first.sent_message_for_to.should eql(["<html><body><h1>Hello Manish Welcome to CLoudfactory!!!!</h1><p>Thanks for using!!!!</p></body></html>"])
          output.first.final_output.first.template.should eql("<html><body><h1>Hello {{user}} Welcome to CLoudfactory!!!!</h1><p>Thanks for using!!!!</p></body></html>")
          output.first.final_output.first.template_variables.user.should eql("Manish")
          output.first.final_output.first.template_variables.email.should eql("{{email}}")
          line.stations.first.worker.class.should eql(CF::MailerRobot)
          line.stations.first.worker.reward.should eql(8)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.to.should eql(["manish.das@sprout-technology.com"])
          line.stations.first.worker.template.should eql("<html><body><h1>Hello {{user}} Welcome to CLoudfactory!!!!</h1><p>Thanks for using!!!!</p></body></html>")
          line.stations.first.worker.template_variables.should eql({"user"=>"Manish"})
        end
      end

      it "should create content_scraping_robot worker for first station in a plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "mailer_robot/plain/create-worker-in-first-station", :record => :new_episodes do
          @template = "<html><body><h1>Hello {{user}} Welcome to CLoudfactory!!!!</h1><p>Thanks for using!!!!</p></body></html>"
          line = CF::Line.new("mailer_robot_8","Digitization")
          input_format = CF::InputFormat.new({:name => "to", :required => "true", :valid_type => "general"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::MailerRobot.create({:to => ["manish.das@sprout-technology.com"], :template => @template, :template_variables => {"user" =>"Manish"}})
          line.stations.first.worker = worker

          run = CF::Run.create(line, "mailer_robot__run_8", [{"to"=> "manish.das@sprout-technology.com"}])
          output = run.final_output
          output.first.final_output.first.recipients_of_to.should eql(["manish.das@sprout-technology.com"])
          output.first.final_output.first.sent_message_for_to.should eql(["<html><body><h1>Hello Manish Welcome to CLoudfactory!!!!</h1><p>Thanks for using!!!!</p></body></html>"])
          output.first.final_output.first.template.should eql("<html><body><h1>Hello {{user}} Welcome to CLoudfactory!!!!</h1><p>Thanks for using!!!!</p></body></html>")
          output.first.final_output.first.template_variables.user.should eql("Manish")
          output.first.final_output.first.template_variables.email.should eql("{{email}}")
          line.stations.first.worker.class.should eql(CF::MailerRobot)
          line.stations.first.worker.reward.should eql(8)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.to.should eql(["manish.das@sprout-technology.com"])
          line.stations.first.worker.template.should eql("<html><body><h1>Hello {{user}} Welcome to CLoudfactory!!!!</h1><p>Thanks for using!!!!</p></body></html>")
          line.stations.first.worker.template_variables.should eql({"user"=>"Manish"})
        end
      end
    end
  end
end