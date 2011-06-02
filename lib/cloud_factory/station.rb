module CloudFactory
  class Station
    include Client
    
    # type of the station, e.g. station = Station.new(line, {:type => "Work"})
    attr_accessor :type
    
    # line attribute is parent attribute for station & is required for making Api call
    attr_accessor :line_id
    
    # ID of the station
    attr_accessor :id

    # ==Initializes a new station
    # ===Usage Example
    #   line = Line.new("Digitize", "Survey")
    #   station = Station.new(line,{:type => "Work"})
    def initialize(options={})
      
        @line_id = options[:line].nil? ? nil : options[:line].id
        @type = options[:type].nil? ? nil : options[:type].camelize
        if !@line_id.nil?
          resp = self.class.post("/lines/#{@line_id}/stations.json", :station => {:type => @type})
          @id = resp.id
          line = options[:line]
          line.stations = self
        end
    end

    # ==Initializes a new station within block 
    # ===Usage Example
    # ===Creating station using block variable
    #   line = CloudFactory::Line.create("Digitize", "Survey") do |l|   
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
    # ===OR creating without variable within block
    #     line = CloudFactory::Line.create("Digitize", "Survey") do
    #       CloudFactory::Station.create(line, :type => "Work") do 
    #         CloudFactory::HumanWorker.new(self, 2, 0.2)
    #         s = self
    #         CloudFactory::StandardInstruction.create(self,{:title => "Enter text from a business card image", :description => "Describe"}) do 
    #           CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
    #           CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
    #           CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})
    #         end 
    #       end
    #     end
    def self.create(options, &block)
      station = Station.new(options)
      if block.arity >= 1
        block.call(station)
      else
        station.instance_eval &block
      end
      station
    end
    
    # ==Creates new instruction for station object
    # ===Usage of worker method for "station" object
    #   line = CloudFactory::Line.create("Digitize", "Survey") do |l|
    #     CloudFactory::Station.create(line, :type => "Work") do |s|
    #       CloudFactory::HumanWorker.new(s, 2, 0.2)
    #     end
    #   end
    def worker worker_instance = nil
      if worker_instance
        @worker_instance = worker_instance
      else
        @worker_instance
      end
    end
    
    def worker=(worker_instance) # :nodoc:
      worker_type = worker_instance.class.to_s.split("::").last
      case worker_type
      when "HumanWorker"
        number = worker_instance.number
        reward = worker_instance.reward
        resp = CloudFactory::HumanWorker.post("/stations/#{self.id}/workers.json", :worker => {:number => number, :reward => reward, :type => "HumanWorker"})
        worker = CloudFactory::HumanWorker.new({})
        resp.to_hash.each_pair do |k,v|
          worker.send("#{k}=",v) if worker.respond_to?(k)
        end
        @worker_instance = worker
        
      else
        number = 1
        reward = 0
        resp = worker_instance.class.post("/stations/#{station.id}/workers.json", :body => {:worker => {:number => 1, :reward => 0, :type => type}})
        worker = worker_instance.class.new({})
        resp.to_hash.each_pair do |k,v|
          worker.send("#{k}=",v) if worker.respond_to?(k)
        end
        @worker_instance = worker
      end
    end
    
    # ==Creates new instruction for station object
    # ===Usage of Instruction method for "station" object
    #   line = CloudFactory::Line.create("Digitize", "Survey") do |l|   
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
    
    # ==Updates Standard Instruction of a station
    # ===Usage example
    #   attrs = {:title => "Enter text from a business card image",
    #       :description => "Describe"
    #   }
    #   line = CloudFactory::Line.create("Digitize", "Survey") do |l|   
    #     CloudFactory::Station.create(l, :type => "work") do |s|
    #       CloudFactory::HumanWorker.new(s, 2, 0.2)
    #       CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    #   line.stations[0].update_instruction({:title => "Enter phone number from a business card image", :description => "Call"})
    def update_instruction(options={})
      @title       = options[:title]
      @description = options[:description]
      self.class.put("/stations/#{self.id}/instruction.json", :instruction => {:title => @title, :description => @description, :type => "StandardInstruction"})
    end
    # ==Returns a particular station of a line
    # ===Usage example for get_station() method
    #   line = CloudFactory::Line.create("Digitize Card", "4dc8ad6572f8be0600000001")
    #   station = CloudFactory::Station.new(line, :type => "Work")
    #
    #   got_station = station.get
    # returns the station object
    def get
      self.class.get("/lines/#{@line.id}/stations/#{self.id}.json")
    end
    
    # ==Returns information of instruction 
    # ===Usage example
    #   line = CloudFactory::Line.create("Digitize", "Survey") do |l|   
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
    #   @got_instruction = line.stations[0].get_instruction
    def get_instruction
      self.class.get("/stations/#{self.id}/instruction.json")
    end
    
    # ==Returns all the stations associated with a particular line
    # ===Usage example for station.all method is
    #   line = CloudFactory::Line.create("Digitize", "Survey") do |l|   
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