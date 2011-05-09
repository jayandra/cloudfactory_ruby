module CloudFactory
  class StandardInstruction
    
    # title of the standard_instruction
    attr_accessor :title
    
    # description about the instruction
    attr_accessor :description
    
    # form_fields for the StandardInstruction
    attr_accessor :form_fields
    
    # ==Initializes a new StandardInstruction
    # ==Usage of standard_instruction.new
    #   attrs = {:title => "Enter text from a business card image",
    #       :description => "Describe"}
    #
    #   instruction = StandardInstruction.new(attrs)
    def initialize(options={})
      @title       = options[:title]
      @description = options[:description]
    end
    
    # ==Initializes a new StandardInstruction within block using Variable
    # ==Usage of "standard_instruction.create(hash) do |block|"
    # ===Creating StandardInstruction using block variable
    #   attrs = {:title => "Enter text from a business card image",
    #       :description => "Describe"}
    #
    #   form_field_values = []
    #   form_field_values << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
    #   form_field_values << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
    #   form_field_values << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")
    #
    #   instruction = CloudFactory::StandardInstruction.create(attrs) do |i|
    #     i.form_fields = form_fields_values
    #   end
    #
    # ===OR without block variable
    #   instruction = CloudFactory::StandardInstruction.create(attrs) do |i|
    #     form_fields form_fields_values
    #   end
    def self.create(instruction, &block)
      instruction = StandardInstruction.new(instruction)
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
    #   form_field_values = []
    #   form_field_values << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
    #   form_field_values << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
    #   form_field_values << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")
    #
    #   form_fields << form_field_values
    def form_fields form_fields = nil
      if form_fields
        @form_fields = form_fields
      else
        @form_fields
      end
    end
  end
end