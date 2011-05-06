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
    #Line.fire_run(@input_data, )
    #  POST http://cf.com/api/v1/lines/:id/runs
    #	 file.csv
    #  InputHeader.new(:label => "file")
  	#  InputHeader.new(:label => "duration")
    # 
    #  FormField.new(:lable => "duration", :value => 300)
    # 
    #  file, duration
    #www., 100
    
    
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