module CloudFactory
  class Line
    
    attr_accessor :name, :input_headers
    
    # =<br><b>Line class for CloudFactory api entities.</b><br><br>
    # ==<b>Initializes a new line</b><br><br>
    # * <b>Example:</b><br><br>
    #
    #     line = Line.new("Digit")
    #--

    def initialize(name, &block)
      self.name = name 
    end
    
  end
end