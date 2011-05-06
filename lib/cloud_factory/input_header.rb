module CloudFactory
  class InputHeader

    attr_accessor :label, :field_type, :value, :required, :validation_format
    
    # =InputHeader class for CloudFactory api entities.
    # ==Initializes a new input_header
    # ---
    # * Syntax for creating new input_header: <b>InputHeader.new(</b> Hash <b>)</b>
    # ==Usage Example:
    #   attrs = {:label => "image_url",
    #     :field_type => "text_data",
    #     :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg",
    #     :required => true,
    #     :validation_format => "url"} 
    #
    #   input_header = InputHeader.new(attrs)
    #--

    def initialize(options={})
      @label              = options[:label]
      @field_type         = options[:field_type]
      @value              = options[:value]
      @required           = options[:required]
      @validation_format  = options[:validation_format]
    end


  end
end