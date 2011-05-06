module CloudFactory
  class Line

    attr_accessor :name, :input_headers, :stations

    # =Line class for CloudFactory api entities.
    # ==Initializes a new line
    # ---
    # * ==Usage Example:
    #
    #     line = Line.new("Digit")
    

    def initialize(name)
      @name = name
      @stations = []
    end
    
    # ==using Line.input_headers method 
    # ---
    # * ==Usage Example:
    #       line = Line.new("line name")
    #       line.input_headers(InputHeader.new)
    #   returns 
    #       line.input_headers
    def input_headers input_headers = nil
      if input_headers
        @input_headers = input_headers
      else
        @input_headers
      end
    end
    

    # ==using Line.stations method 
    # ---
    # * ==Usage Example:
    #       line = Line.new("line name")
    #       line.stations(Station.new)
    #   returns 
    #       line.stations
    def stations station = nil
      if station
        @stations << station
      else
        @stations
      end
    end
    
    # ==Initializes a new line
    # ---
    # * ==Usage Example:
    #   * ===creating Line within block using variable
    #       attrs = {:label => "image_url",
    #         :field_type => "text_data",
    #         :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg",
    #         :required => true,
    #         :validation_format => "url"} 
    #
    #       input_header = InputHeader.new(attrs)
    #
    #       Line.create("Line name") do |line|
    #         line.input_headers << input_header
    #       end
    # 
    #   * ===OR creating without variable
    #       attrs = {:label => "image_url",
    #         :field_type => "text_data",
    #         :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg",
    #         :required => true,
    #         :validation_format => "url"} 
    #
    #       input_header = InputHeader.new(attrs)
    #
    #       Line.create("Line name") do
    #         input_headers << input_header
    #       end
    #--
    def self.create(name, &block)
      line = Line.new(name)
      if block.arity >= 1
        block.call(line)
      else
        line.instance_eval &block
      end
      line
    end
  end
end