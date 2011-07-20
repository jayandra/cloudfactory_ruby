module CF
  
  # ==Initializes a new robot_worker
  # * Includes Worker Module
  # * Syntax for creating new robot_worker: <b>RobotWorker.new(</b> number,reward <b>)</b>
  # * where the default value of number is 1
  # ==Usage Example
  #   line = CF::Line.create("Digitize", "Survey") do |l|   
  #     CF::Station.create(l, :type => "work") do |s|
  #       CF::RobotWorker.new(s, 2, 0.2)
  #     end
  #   end
  #
  class TermExtraction
    
    include Worker

  end
end