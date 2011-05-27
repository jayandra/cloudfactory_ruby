module CloudFactory
  
  # ==Initializes a new robot_worker
  # * Includes Worker Module
  # * Syntax for creating new robot_worker: <b>RobotWorker.new(</b> number,reward <b>)</b>
  # * where the default value of number is 1
  # ==Usage Example
  #   line = CloudFactory::Line.create("Digitize", "Survey") do |l|   
  #     CloudFactory::Station.create(l, :type => "work") do |s|
  #       CloudFactory::RobotWorker.new(s, 2, 0.2)
  #     end
  #   end
  #
  class MediaConverterRobot
    
    include Worker

  end
end