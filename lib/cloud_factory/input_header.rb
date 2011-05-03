module CloudFactory
  class InputHeader
    
    attr_accessor :label, :field_type, :value, :required, :validation_format
    
    def initialize(options={})
      @label              = options[:label]
      @field_type         = options[:field_type]
      @value              = options[:value]
      @required           = options[:required]
      @validation_format  = options[:validation_format]
    end
    
    
  end
end