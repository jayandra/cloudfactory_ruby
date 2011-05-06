module CloudFactory
  class Station
    # Staion name
    attr_accessor :name
    
    # for creating worker instance 
    attr_accessor :worker_instance
    
    # for creating instruction instance
    attr_accessor :instruction_instance
    
    # =Station class for CloudFactory api entities.
    # ==Initializes a new station
    # ==Usage Example
    #     station = Station.new("station name")
    def initialize(name)
      @name = name
    end
    
    # =Station class for CloudFactory api entities.
    # ==Initializes a new station within block 
    # ---
    # 
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
    # ===OR creating without variable within block
    #     station = Station.new("station name") do
    #       worker worker
    #
    #       instruction CloudFactory::StandardInstruction.create(:title => "Enter text from a business card image", 
    #                             :description => "Describe") do |i|
    #
    #         i.form_fields = form_field_value
    #       end
    def self.create(name, &block)
      station = Station.new(name)
      if block.arity >= 1
        block.call(station)
      else
        station.instance_eval &block
      end
      station
    end
    
    # * Creates new instruction for station object
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
    
    # * Creates new instruction for station object
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
    
  end
end