module CloudFactory
  
  # ==Initializes a new human_worker 
  # * Includes Worker Module
  # * Syntax for creating new robot_worker: <b>HumanWorker.new(</b> number,reward <b>)</b>
  # * where the default value of number is 1
  # ==Usage Example
  #   worker = HumanWorker.new(2, 0.2)
  class HumanWorker
    
    include Worker
    
  end
end