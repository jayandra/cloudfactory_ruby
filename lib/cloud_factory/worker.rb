module CloudFactory
  class Worker
    
    attr_accessor :number, :reward
    
    def initialize(number=1, reward)
      @number = number
      @reward = reward
    end

  end
end