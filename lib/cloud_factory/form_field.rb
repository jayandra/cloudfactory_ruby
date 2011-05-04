module CloudFactory
  class FormField
    
    attr_accessor :label, :field_type, :required

    def initialize(options={})
      @label      = options[:label]
      @field_type = options[:field_type]
      @required   = options[:required]
    end
  end
end