module CloudFactory
  class Run
    include Client

    # title of the "run" object
    attr_accessor :title

    # file attributes to upload
    attr_accessor :file
    
    # line attribute with which run is associated
    attr_accessor :line
    
    # ==Initializes a new Run
    # ==Usage Example:
    #     
    #   line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
    #     CloudFactory::InputHeader.new({:label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CloudFactory::InputHeader.new({:label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CloudFactory::Station.create({:line => l, :type => "work") do |s|
    #       CloudFactory::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CloudFactory::StandardInstruction.create(:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CloudFactory::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})            
    #       end
    #     end
    #   end
    # 
    #   run = CloudFactory::Run.new(line, "run name", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
    def initialize(line, title, file)
      @line = line
      @title = title
      @file = file
      @input_data =[]
      resp = self.class.post("/lines/#{@line.id}/runs.json", {:run => {:title => @title}, :file => File.new(@file, 'rb')})
      @id = resp.id
    end
    
    # ==Creates a new Run
    # ==Usage Example:
    #     
    #   line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
    #     CloudFactory::InputHeader.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CloudFactory::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CloudFactory::Station.create({:line => l, :type => "work") do |s|
    #       CloudFactory::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CloudFactory::StandardInstruction.create(:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CloudFactory::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})            
    #       end
    #     end
    #   end
    #
    #   run = CloudFactory::Run.create(line, "run name", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
    def self.create(line, title, file)
      Run.new(line, title, file)
    end
    
    def get # :nodoc:
      self.class.get("/lines/#{@line.id}/runs/#{@id}.json")
    end
  end
end