require 'active_support/concern'

module CloudFactory
  module Worker
    extend ActiveSupport::Concern
    
    included do |base|
      
      host = base.to_s.split("::").last
      
      # Number of worker 
      attr_accessor :number
      # Amount of money assigned for worker
      attr_accessor :reward
      
      case host
      when "HumanWorker"
        
        # Initializes new worker
        def initialize(number=1, reward)
          @number = number
          @reward = reward
        end
        
      else
        
        # Creates new worker 
        def self.create
          worker = self.new
          worker.instance_eval do
            @number = 1
            @reward = nil
          end
          worker
          #POST http://cf.com/api/v1/stations/1/worker
        end
      end
    end
  end
end