module CloudFactory
  class Station
    include Client
    include ClientRequestResponse
    
    
    # type of the station, e.g. station = Station.new(line, {:type => "Work"})
    attr_accessor :type
    
    # line attribute is parent attribute for station & is reuired for making Api call
    attr_accessor :line
    
    # station_id attribute is required to be stored for making Api calls
    attr_accessor :station_id

    # ==Initializes a new station
    # ==Usage Example
    #     station = Station.new("station name")
    def initialize(line, options={})
      @line = line
      @type = options[:type].camelize
      resp = self.class.post("/lines/#{@line.id}/stations.json", :body => {:station => {:type => @type}})
      debugger
      @station_id = resp._id
    end

    # ==Initializes a new station within block 
    # ==Usage Example
    # ===Creating station using block variable
    #     worker = HumanWorker.new(2, 0.2)
    #     form_field_value = []
    #     form_field_value << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
    #     form_field_value << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
    #     form_field_value << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")
    #       
    #     station = Station.new("station name") do |s|
    #       s.worker = worker
    #       
    #       s.instruction = CloudFactory::StandardInstruction.create(:title => "Enter text from a business card image",
    #                             :description => "Describe") do |i|
    #     
    #         i.form_fields = form_field_value
    #       end
    #     end
    # ===OR creating without variable within block
    #     station = Station.new("station name") do
    #       worker worker
    #
    #       instruction CloudFactory::StandardInstruction.create(:title => "Enter text from a business card image", 
    #                             :description => "Describe") do |i|
    #
    #         i.form_fields = form_field_value
    #       end
    def self.create(line, name, &block)
      station = Station.new(line, name)
      if block.arity >= 1
        block.call(station)
      else
        station.instance_eval &block
      end
      station
    end
    
    # ==Creates new instruction for station object
    # ==Usage of worker method for "station" object
    #     worker = HumanWorker.new(2, 0.2)
    #     
    #     station.worker = worker
    def worker worker_instance = nil
      if worker_instance
        @worker_instance = worker_instance
      else
        @worker_instance
      end
    end
    def worker=(worker_instance) # :nodoc:
      @worker_instance = worker_instance
    end
    
    # ==Creates new instruction for station object
    # ==Usage of Instruction method for "station" object
    #
    #       form_field_value = []
    #       form_field_value << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
    #       form_field_value << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
    #       form_field_value << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")    
    #
    #       station.instruction = CloudFactory::StandardInstruction.create(:title => "Enter text from a business card image",
    #                             :description => "Describe") do |i|
    #
    #         i.form_fields = form_field_value
    #       end
    def instruction instruction_instance = nil
      if instruction_instance
        @instruction_instance = instruction_instance
      else
        @instruction_instance
      end
    end
    def instruction=(instruction_instance) # :nodoc:
      @instruction_instance = instruction_instance
    end
    
    def update(line, options={})
      @type = options[:type]
      self.class.put("/lines/#{@line.id}/stations/#{station_id}.json", :body => {:station => {:type => @type}})
    end
    
    def self.get_station(station)
      debugger
      get("/lines/#{station.line.id}/stations/#{station.station_id}.json")
    end
  end
end