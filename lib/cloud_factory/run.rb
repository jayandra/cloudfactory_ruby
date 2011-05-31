module CloudFactory
  class Run
    include Client

    # title of the "run" object
    attr_accessor :title

    # file attributes to upload
    attr_accessor :file
    
    # line attribute with which run is associated
    attr_accessor :line
    
    ## input_data for the Run
    #attr_accessor :input_data
    
    # ==Initializes a new Run
    # ==Usage Example:
    #     
    #   line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
    #     CloudFactory::InputHeader.new(l, attrs_1)
    #     CloudFactory::InputHeader.new(l, attrs_2)
    #     CloudFactory::Station.create(l, :type => "work") do |s|
    #       CloudFactory::HumanWorker.new(s, 2, 0.2)
    #       CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})            
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
      
      if line.id.nil?
        line_id = line._id
      else
        line_id = line.id
      end
      
      resp = self.class.post("/lines/#{line_id}/runs.json", {:run => {:title => @title}, :file => File.new(@file, 'rb')})
      @id = resp._id
    end
    
    # ==Creates a new Run
    # ==Usage Example:
    #     
    #   line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
    #     CloudFactory::InputHeader.new(l, attrs_1)
    #     CloudFactory::InputHeader.new(l, attrs_2)
    #     CloudFactory::Station.create(l, :type => "work") do |s|
    #       CloudFactory::HumanWorker.new(s, 2, 0.2)
    #       CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})            
    #       end
    #     end
    #   end
    # 
    #   run = CloudFactory::Run.create(line, "run name", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
    def self.create(line, title, file)
      Run.new(line, title, file)
    end
    
    def get
      self.class.get("/lines/#{@line.id}/runs/#{@id}.json")
    end
  end
end