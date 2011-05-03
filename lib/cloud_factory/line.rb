module CloudFactory
  class Line
    
    attr_accessor :name, :input_headers
    
    def initialize(name, &block)
      self.name = name
      
    end
    
  end
end