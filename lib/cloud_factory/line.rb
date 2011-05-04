module CloudFactory
  class Line
    
    attr_accessor :name, :input_headers, :stations
    
<<<<<<< HEAD
    # =<br><b>Line class for CloudFactory api entities.</b><br><br>
    # ==<b>Initializes a new line</b><br><br>
    # * <b>Example:</b><br><br>
    #
    #     line = Line.new("Digit")
    #--

    def initialize(name, &block)
      self.name = name 
=======
    def initialize(name)
      @name = name
      @input_headers = []
      @stations = []
>>>>>>> d5f1f559a41dfe7b8f70858e1de5de45bec99cf3
    end
    
    # line = Line.new("line name")
    # line.input_headers(InputHeader.new)
    # line.input_headers
    def input_headers input_header = nil
      if input_header
        @input_headers << input_header
      else
        @input_headers
      end
    end

    # line = Line.new("line name")
    # line.input_headers(InputHeader.new)
    # line.input_headers
    def stations station = nil
      if station
        @stations << station
      else
        @stations
      end
    end
    
    # Line.create("Line name") do |line|
    #   line.input_headers InputHeader.new
    # end
    # 
    # OR
    #
    # Line.create("Line name") do
    #   input_headers InputHeader.new
    # end
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