module CloudFactory
  class Worker
    
    attr_accessor :number, :reward
    
    # =Worker class for CloudFactory api entities.
    # * ==Initializes a new worker
    # ---
    # * ==Usage Example:
    #     worker = Worker.new("Digit")
    #--
    
    def initialize(number=1, reward)
      @number = number
      @reward = reward
    end

  end
end