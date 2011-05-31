module CloudFactory
  class StandardInstruction
    include Client
    
    # title of the standard_instruction
    attr_accessor :title
    
    # description about the instruction
    attr_accessor :description
    
    # form_fields for the StandardInstruction
    
    # station attributes required to store station information
    attr_accessor :station
    
    # ID of Standard Instruction
    attr_accessor :id
    
    # ==Initializes a new StandardInstruction
    # ==Usage of standard_instruction.new
    #   attrs = {:title => "Enter text from a business card image",
    #       :description => "Describe"}
    #
    #   instruction = StandardInstruction.new(attrs)
    def initialize(station, options={})
      @form_fields =[]
      @station = station
      @title       = options[:title]
      @description = options[:description]
      resp = self.class.post("/stations/#{station.id}/instruction.json", :instruction => {:title => @title, :description => @description, :_type => "StandardInstruction"})
      @id = resp._id
      station.instruction = self
    end
    
    # ==Initializes a new StandardInstruction within block using Variable
    # ==Usage of "standard_instruction.create(hash) do |block|"
    # ===Creating StandardInstruction using block variable
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
    # ===OR without block variable
    #   line = CloudFactory::Line.create("Digitize", "Survey") do |l|   
    #     CloudFactory::Station.create(l, :type => "work") do |s|
    #       CloudFactory::HumanWorker.new(s, 2, 0.2)
    #       CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do
    #         CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    #
    def self.create(station, options, &block)
      instruction = StandardInstruction.new(station, options)
      if block.arity >= 1
        block.call(instruction)
      else
        instruction.instance_eval &block
      end
      instruction
    end
    
    # ==appending different form_fields 
    # ===Syntax for FormField method is form_fields << form_field_values
    # ==Usage of form_fields method
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
    def form_fields form_fields = nil
      if form_fields
        @form_fields << form_fields
      else
        @form_fields
      end
    end
    def form_fields=(form_fields) # :nodoc:
      @form_fields << form_fields
    end
    # ==Deletes Standard Instruction of a station
    # ==Usage example
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
    #   station = line.stations[0]
    #
    #   CloudFactory::StandardInstruction.delete_instruction(station)
    # deletes standard_instruction of a station
    def self.delete_instruction(station)
      delete("/stations/#{station.id}/instruction.json")
    end
  end
end