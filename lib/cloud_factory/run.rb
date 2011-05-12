module CloudFactory
  class Run
    
    # name of the "run" object, e.g. run = Run.new("run_name")
    attr_accessor :name
    
    # input_data for the Run
    attr_accessor :input_data
    
    # ==Initializes a new Run
    # ==Usage Example:
    #     
    #   run = Run.new("RunName")
    def initialize(name)
      @name = name
      @input_data =[]
    end
    
    # ==Initializes a new run
    # ==Usage of run.create("run_name") do |block|
    # ===creating Run within block using variable
    #   run = CloudFactory::Run.create("run name") do |r|
    #     r.input_data [{:name => "Bob Smith", :age => 23}, {:name => "John Doe", :age => 24}]
    #   end
    # 
    # ===OR creating without variable
    #   run = CloudFactory::Run.create("run name") do
    #     input_data [{:name => "Bob Smith", :age => 23}, {:name => "John Doe", :age => 24}]
    #   end
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