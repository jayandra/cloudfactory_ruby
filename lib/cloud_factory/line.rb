module CloudFactory
  class Line

    attr_accessor :name, :input_headers, :stations

    # =<br><b>Line class for CloudFactory api entities.</b><br><br>
    # ==<b>Initializes a new line</b><br><br>
    # ---
    # <br>
    # * <b>Usage Example:</b><br><br>
    #
    #     line = Line.new("Digit")
    

    def initialize(name)
      @name = name
      @input_headers = []
      @stations = []
    end
    
    # ==using Line.input_headers method <br><br>
    # ---
    # <br>
    #   * <b>Usage Example:</b><br><br>
    #       line = Line.new("line name")
    #       line.input_headers(InputHeader.new)
    #     <br>returns 
    #       line.input_headers
    def input_headers input_header = nil
      if input_header
        @input_headers << input_header
      else
        @input_headers
      end
    end

    # ==using Line.stations method <br><br>
    # ---
    # <br>
    #   * <b>Usage Example:</b><br><br>
    #       line = Line.new("line name")
    #       line.stations(Station.new)
    #     <br>returns 
    #       line.stations
    def stations station = nil
      if station
        @stations << station
      else
        @stations
      end
    end
    
    # ==<b>Initializes a new line</b><br><br>
    # ---
    # <br>
    # * <b>Usage Example:</b><br><br>
    #   <br>creating Line within block using variable
    #     attrs = {:label => "image_url",
    #       :field_type => "text_data",
    #       :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg",
    #       :required => true,
    #       :validation_format => "url"} 
    #
    #     input_header = InputHeader.new(attrs)
    #
    #     Line.create("Line name") do |line|
    #       line.input_headers << input_header
    #     end
    # 
    #   <br>OR creating without variable
    #     attrs = {:label => "image_url",
    #       :field_type => "text_data",
    #       :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg",
    #       :required => true,
    #       :validation_format => "url"} 
    #
    #     input_header = InputHeader.new(attrs)
    #
    #     Line.create("Line name") do
    #       input_headers << input_header
    #     end
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