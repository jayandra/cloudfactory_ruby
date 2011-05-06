module CloudFactory
  class FormField
    attr_accessor :label, :field_type, :required
    # =FormField class for CloudFactory api entities.
    # ==Initializes a new form_field
    # ---
    # * ==Usage Example:
    #     form_field = FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
    #--
    def initialize(options={})
      @label      = options[:label]
      @field_type = options[:field_type]
      @required   = options[:required]
    end
  end
end