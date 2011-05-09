module CloudFactory
  class Line
    include Client
    include ClientRequestResponse
    
    attr_accessor :name
    #attr_accessor :input_header_instance
    #attr_accessor :station_instance

    # =Line class for CloudFactory api entities.
    # ==Initializes a new line
    # ==Usage of line.new("line_name")
    #
    #     line = Line.new("Digit")
    

    def initialize(name)
      @name = name
      @stations = []
      self.class.post("/lines.json", :body => {:line => {:name => name}})
    end
    
    # ==using Line.input_headers method 
    # ==Usage of line.input_headers(input_header)
    #     line = Line.new("line name")
    #     line.input_headers = InputHeader.new
    # returns 
    #     line.input_headers
    def input_headers input_headers_value = nil
      if input_headers_value
        @input_headers_value = input_headers_value
      else
        @input_headers_value
      end
    end
    def input_headers=(input_headers_value) # :nodoc:
      @input_headers_value = input_headers_value
    end

    # ==using Line.stations method 
    # ==Usage of line.stations << station
    #     line = Line.new("line name")
    #     station = Station.new("station_name")
    #     line.stations << station
    # returns 
    #     line.stations
    def stations stations = nil
      if stations
        @stations << stations
      else
        @stations
      end
    end
    def stations=(stations) # :nodoc:
      @stations = stations
    end
    # ==Initializes a new line
    # ==Usage of line.create("line_name") do |block|
    # ===creating Line within block using variable
    #     attrs = {:label => "image_url",
    #       :field_type => "text_data",
    #       :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg",
    #       :required => true,
    #       :validation_format => "url"} 
    #
    #     input_header = InputHeader.new(attrs)
    #
    #     Line.create("line_name") do |line|
    #       line.input_headers = [input_header]
    #     end
    # 
    # ===OR creating without variable
    #     attrs = {:label => "image_url",
    #       :field_type => "text_data",
    #       :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg",
    #       :required => true,
    #       :validation_format => "url"} 
    #
    #     input_header = InputHeader.new(attrs)
    #
    #     Line.create("line_name") do
    #       input_headers  [input_header]
    #     end
    def self.create(name, &block)
      line = Line.new(name)
      if block.arity >= 1
        block.call(line)
      else
        line.instance_eval &block
      end
      post("/lines.json", :body => {:line => {:name => "First Line"}})
      line
    end
    
  end
end