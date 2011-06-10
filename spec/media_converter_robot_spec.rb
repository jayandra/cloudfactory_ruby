require 'spec_helper'

module CF
  describe CF::MediaConverterRobot do
    context "create a google translator worker" do
      xit "the plain ruby way" do
        WebMock.allow_net_connect!
        
        attrs_1 = {:label => "url",
          :field_type => "text_data",
          :value => "Apple", 
          :required => true, 
          :validation_format => "url"
        }

        line = CF::Line.create("Digitize Card","Digitization") do |l|
          CF::InputHeader.new(l, attrs_1)
          #CF::InputHeader.new(l, attrs_2) 
          CF::Station.create(l, :type => "work") do |s|
            CF::MediaConverterRobot.create(s)
            CF::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
              CF::FormField.new(s, {:label => "to", :value => "wma", :required => "true"})
              CF::FormField.new(s, {:label => "audio_quality", :value => "128", :required => "true"})
              CF::FormField.new(s, {:label => "video_quality", :value => "2", :required => "true"})
            end
          end
        end
        
        # got_line = CF::Line.find(line.id)
        # got_line.stations.first.instruction.form_fields.first.label.should eq("to")
        run = CF::Run.create(line, "run name", File.expand_path("../../fixtures/input_data/media_converter_robot.csv", __FILE__))
      end
    end
  end
end
