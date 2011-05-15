module CloudFactory
  
  # ==Initializes a new robot_worker
  # * Includes Worker Module
  # * Syntax for creating new robot_worker: <b>RobotWorker.new(</b> number,reward <b>)</b>
  # * where the default value of number is 1
  # ==Usage Example
  #   worker = RobotWorker.new(2, 0.2)
  class GoogleTranslator
    
    include Worker

  end
end