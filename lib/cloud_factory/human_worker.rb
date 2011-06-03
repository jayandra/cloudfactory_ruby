module CloudFactory
  
  # ==Initializes a new human_worker 
  # * Includes Worker Module
  # * Syntax for creating new robot_worker: <b>HumanWorker.new(</b> number,reward <b>)</b>
  # * where the default value of number is 1
  # ==Usage Example
  #   line = CloudFactory::Line.create("Digitize", "Survey") do |l|   
  #     CloudFactory::Station.create({:line => l, :type => "work"}) do |s|
  #       CloudFactory::HumanWorker.new({:station => s, :number => 1, :reward => 20})
  #     end
  #   end
  #
  class HumanWorker
    
    include Worker
    
  end
end