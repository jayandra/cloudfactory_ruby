module CloudFactory
  class Station
    
    attr_accessor :name, :worker, :instruction
    
    # =<br><b>Station class for CloudFactory api entities.</b><br><br>
    # ==<b>Initializes a new Station</b><br><br>
    # ---
    # <br>
    # * <b>Usage Example:</b><br><br>
    #     station = Station.new("station name")
    def initialize(name)
      @name = name
    end
    
    # =<br><b>Station class for CloudFactory api entities.</b><br><br>
    # ==<b>Initializes a new Station within block using variable</b><br><br>
    # ---
    # <br>
    # * <b>Usage Example:</b><br><br>
    #     
    #     worker = HumanWorker.new(2, 0.2)
    #     form_field_value = []
    #     form_field_value << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
    #     form_field_value << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
    #     form_field_value << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")
    #     
    #     station = Station.new("station name") do |s|
    #       s.worker = worker
    #       s.instruction = CloudFactory::StandardInstruction.create(:title => "Enter text from a business card image", :description => "Describe") do |i|
    #         i.form_fields = form_field_value
    #       end
    #   <br>OR creating without variable within block
    #
    #     station = Station.new("station name") do
    #       worker worker
    #       instruction CloudFactory::StandardInstruction.create(:title => "Enter text from a business card image", :description => "Describe") do |i|
    #        i.form_fields = form_field_value
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
    
    # ==Usage of Station.worker method<br><br>
    # ---
    # <br>
    # * <b>Usage Example:</b><br><br>
    #     worker = HumanWorker.new(2, 0.2)
    #
    #     Station.worker = worker  
    def worker worker = nil
      if worker
        @worker = worker
      else
        @worker
      end
    end
    
    # ==Usage of Station.instruction method<br><br>
    # ---
    # <br>
    # * <b>Usage Example:</b><br><br>
    #     instruction = HumanWorker.new(2, 0.2)
    #
    #     Station.worker = CloudFactory::StandardInstruction.create(:title => "Enter text from a business card image", :description => "Describe") do |i|
    #       i.form_fields = form_field_value
    #     end
    def instruction instruction = nil
      if instruction
        @instruction = instruction
      else
        @instruction
      end
    end
    
  end
end