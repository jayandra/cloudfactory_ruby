module CloudFactory
  class Station
    
    attr_accessor :name, :worker, :instruction
    
    def initialize(name)
      @name = name
    end
    
    def self.create(name, &block)
      station = Station.new(name)
      if block.arity >= 1
        block.call(station)
      else
        station.instance_eval &block
      end
      station
    end
    
    def worker worker = nil
      if worker
        @worker = worker
      else
        @worker
      end
    end
    
    def instruction instruction = nil
      if instruction
        @instruction = instruction
      else
        @instruction
      end
    end
    
  end
end