module CloudFactory
  class Worker
    
    attr_accessor :number, :reward
    
    # <br><b>Worker class for CloudFactory api entities.</b><br>
    # <ul><br><b>Initializes a new worker</b><br><ul>
    # <br><li><b>Example:</b></li><br>
    #   worker = Worker.new("Digit")
    #--
    
    def initialize(number=1, reward)
      @number = number
      @reward = reward
    end

  end
end