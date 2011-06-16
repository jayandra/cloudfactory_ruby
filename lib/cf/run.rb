module CF
  class Run
    include Client

    # title of the "run" object
    attr_accessor :title

    # file attributes to upload
    attr_accessor :file, :data

    # line attribute with which run is associated
    attr_accessor :line

    attr_accessor :id

    # ==Initializes a new Run
    # ==Usage Example:
    #
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputHeader.new({:label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputHeader.new({:label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::StandardInstruction.create(:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    #
    #   run = CF::Run.new(line, "run name", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
    def initialize(line, title, input)
      @line = line
      @title = title
      if File.exist?(input)
        @file = input
        @param_data = File.new(input, 'rb')
        @param_for_input = :file
      else
        @data = input
        @param_data = input
        @param_for_input = :data
      end
      @input_data =[]
      resp = self.class.post("/lines/#{@line.id}/runs.json", {:run => {:title => @title}, @param_for_input => @param_data})
      @id = resp.id
    end

    # ==Creates a new Run
    # ==Usage Example:
    #
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputHeader.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::StandardInstruction.create(:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    #
    #   run = CF::Run.create(line, "run name", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
    def self.create(line, title, file)
      Run.new(line, title, file)
    end

    def get # :nodoc:
      self.class.get("/lines/#{@line.id}/runs/#{@id}.json")
    end
  end
end