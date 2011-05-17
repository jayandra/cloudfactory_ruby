module CloudFactory
  class Station
    include Client
    include ClientRequestResponse
    
    
    # type of the station, e.g. station = Station.new(line, {:type => "Work"})
    attr_accessor :type
    
    # line attribute is parent attribute for station & is required for making Api call
    attr_accessor :line
    
    # ID of the station
    attr_accessor :id

    # ==Initializes a new station
    # ===Usage Example
    #     station = Station.new("station name")
    def initialize(line, options={})
      @line = line
      @type = options[:type].camelize
      resp = self.class.post("/lines/#{@line.id}/stations.json", :body => {:station => {:type => @type}})
      @id = resp._id
    end

    # ==Initializes a new station within block 
    # ===Usage Example
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
    # ===Usage of worker method for "station" object
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
    # ===Usage of Instruction method for "station" object
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
    
    # ==Updates a station 
    # ===Usage example for update method is 
    #   line = CloudFactory::Line.new("Digitize Card", "4dc8ad6572f8be0600000001")
    #   station = CloudFactory::Station.new(line, :type => "Work")
    #   station.update(:type => "Tournament")
    # ===This changes the type of the "station" object from "Work" to "Tournament"
    def update(options={})
      @type = options[:type]
      self.class.put("/lines/#{@line.id}/stations/#{self.id}.json", :body => {:station => {:type => @type}})
    end
    
    # ==Updates StandardInstruction of a station
    # ===Usage example
    #   attrs = {:title => "Enter text from a business card image",
    #       :description => "Describe"
    #   }
    # 
    #   form_fields = []
    #   form_fields << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
    #   form_fields << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
    #   form_fields << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")
    # 
    #   line = CloudFactory::Line.create("Digitize Card", "Digitization") do |l|
    #     l.stations = CloudFactory::Station.create(l, :type => "work") do |s|
    #       s.instruction = CloudFactory::StandardInstruction.create(s, attrs) do |i|
    #         i.form_fields = form_fields
    #       end
    #   
    #       s.update_instruction({:title => "Enter phone number from a business card image", :description => "Call"})
    #     end
    #   end
    def update_instruction(options={})
      @title       = options[:title]
      @description = options[:description]
      self.class.put("/stations/#{self.id}/instruction.json", :body => {:instruction => {:title => @title, :description => @description, :type => "StandardInstruction"}})
    end
    # ==Returns a particular station of a line
    # ===Usage example for get_station() method
    #   line = CloudFactory::Line.create("Digitize Card", "4dc8ad6572f8be0600000001")
    #   station = CloudFactory::Station.new(line, :type => "Work")
    #
    #   got_station = station.get_station
    # returns the station object
    def get_station
      self.class.get("/lines/#{@line.id}/stations/#{self.id}.json")
    end
    
    # ==Returns information of instruction 
    # ===Usage example
    #   attrs = {:title => "Enter text from a business card image",
    #     :description => "Describe"
    #   }
    # 
    #   form_fields = []
    #   form_fields << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
    #   form_fields << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
    #   form_fields << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")
    # 
    #   line = CloudFactory::Line.create("Digitize Card", "Digitization") do |l|
    #     l.stations = CloudFactory::Station.create(l, :type => "work") do |s|
    #       s.instruction = CloudFactory::StandardInstruction.create(s, attrs) do |i|
    #         i.form_fields = form_fields
    #       end
    #     @got_instruction = s.get_instruction
    #     end
    #   end
    def get_instruction
      self.class.get("/stations/#{self.id}/instruction.json")
    end
    
    # ==Returns all the stations associated with a particular line
    # ===Usage example for station.all method is
    #   line = CloudFactory::Line.create("Digitize Card", "4dc8ad6572f8be0600000001") do |l|
    #     station = []
    #     station << CloudFactory::Station.new(line, :type => "Work")
    #     station << CloudFactory::Station.new(line, :type => "Tournament")
    #     l.stations = station
    #   end
    #   CloudFactory::Station.all(line)
    # returns all stations
    def self.all(line)
      get("/lines/#{line.id}/stations.json")
    end
    
    # ==Deletes a station
    # * We need to pass line object with which desired station associated with as an argument to delete a station
    # ===Usage example for delete method
    #   line = CloudFactory::Line.new("Digitize Card", "4dc8ad6572f8be0600000001")
    #   station = CloudFactory::Station.new(line, :type => "Work")
    #   station.delete
    def delete
      self.class.delete("/lines/#{@line.id}/stations/#{self.id}.json")
    end
  end
end