module CloudFactory
  class StandardInstruction
    
    attr_accessor :title, :description, :form_fields
    
    # =<br><b>StandardInstruction class for CloudFactory api entities.</b><br><br>
    # ==<b>Initializes a new StandardInstruction</b><br><br>
    # ---
    # <br>
    # * <b>Usage Example:</b><br><br>
    #     attrs = {:title => "Enter text from a business card image",
    #         :description => "Describe"}
    #
    #     instruction = StandardInstruction.new(attrs)
    def initialize(options={})
      @title       = options[:title]
      @description = options[:description]
    end
    
    # =<br><b>StandardInstruction class for CloudFactory api entities.</b><br><br>
    # ==<b>Initializes a new StandardInstruction within block using Variable</b><br><br>
    # ---
    # <br>
    # * <b>Usage Example:</b><br><br>
    #     attrs = {:title => "Enter text from a business card image",
    #         :description => "Describe"}
    #
    #     form_field_values = []
    #     form_field_values << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
    #     form_field_values << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
    #     form_field_values << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")
    #
    #     instruction = CloudFactory::StandardInstruction.create(attrs) do |i|
    #       i.form_fields = form_fields_values
    #     end
    #
    #   <br>OR without block variable
    #     instruction = CloudFactory::StandardInstruction.create(attrs) do |i|
    #       form_fields form_fields_values
    #     end
    #--
    def self.create(instruction, &block)
      instruction = StandardInstruction.new(instruction)
      if block.arity >= 1
        block.call(instruction)
      else
        instruction.instance_eval &block
      end
      instruction
    end
    
    # ==Usage of formfield<br><br>
    # ---
    # <br>
    # Syntax for FormField method is form_fields << form_field_values<br><br>
    # * <b>Usage Example:</b><br><br>
    #     form_field_values = []
    #     form_field_values << CloudFactory::FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
    #     form_field_values << CloudFactory::FormField.new(:label => "Middle Name", :field_type => "SA")
    #     form_field_values << CloudFactory::FormField.new(:label => "Last Name", :field_type => "SA", :required => "true")
    #
    #     form_fields << form_field_values
    #
    def form_fields form_fields = nil
      if form_fields
        @form_fields = form_fields
      else
        @form_fields
      end
    end
  end
end