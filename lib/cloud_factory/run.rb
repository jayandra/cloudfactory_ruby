module CloudFactory
  class Run
    
    attr_accessor :name, :input_data

    def initialize(name)
      @name = name
      @input_data =[]
    end
    
    def self.create(name, &block)
      run = Run.new(name)
      if block.arity >= 1
        block.call(run)
      else
        run.instance_eval &block
      end
      run
    end
    
    def input_data input_data = nil
      if input_data
        input_data.each do |i|
          @input_data << i
        end
      else
        @input_data
      end
    end
    
  end
end