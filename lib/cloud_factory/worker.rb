require 'active_support/concern'

module CloudFactory
  module Worker
    extend ActiveSupport::Concern
    include Client
    include ClientRequestResponse

    included do |base|

      host = base.to_s.split("::").last

      # Number of worker 
      attr_accessor :number
      # Amount of money assigned for worker
      attr_accessor :reward
      # attr_accessor :station

      case host
      when "HumanWorker"

        # Initializes new worker
        def initialize( station, number=1, reward )
          # @station =  station
          @number = number
          @reward = reward
          CloudFactory::HumanWorker.post("/stations/#{station.id}/workers.json", :body => 
          {:worker => {:number => @number, :reward => @reward, :type => "HumanWorker"}})
          station.worker = self
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