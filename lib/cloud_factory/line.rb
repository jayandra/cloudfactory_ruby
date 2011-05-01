module CloudFactory
  class Line
    
    attr_accessor :name
    
    def initialize(name, &block)
      self.name = name
    end
    
  end
end