module CloudFactory
  class FormField
    
    # Label for "form_field" object, e.g. :label => "First Name"
    attr_accessor :label
    
    # field_type for "form_field" object, e.g. :field_type => "SA"
    attr_accessor :field_type
    
    # required boolean either true or false, e.g. :required => "true" & if false then you don't need to mention  
    attr_accessor :required
    
    # =FormField class for CloudFactory api entities.
    # ==Initializes a new "form_field" object
    # ==Usage of form_field.new(hash):
    #     form_field = FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
    #--
    def initialize(options={})
      @label      = options[:label]
      @field_type = options[:field_type]
      @required   = options[:required]
    end
  end
end