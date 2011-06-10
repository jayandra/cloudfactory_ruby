module CF
  module Worker
    extend ActiveSupport::Concern
    include Client

    included do |base|
      host = base.to_s.split("::").last
      # Number of worker 
      attr_accessor :number
      # Amount of money assigned for worker
      attr_accessor :reward
      attr_accessor :station
      attr_accessor :id

      case host
      when "HumanWorker"
        # Initializes new worker
        def initialize(options={})
          @station = options[:station]
          @number  = options[:number].nil? ? 1 : options[:number]
          @reward  = options[:reward]
          if !@station.nil?
            CF::HumanWorker.post("/stations/#{@station.id}/workers.json", :worker => {:number => @number, :reward => @reward, :type => "HumanWorker"})
            station.worker = self
          end
        end
      else
        # Creates new worker 
        def self.create(station)
          worker = self.new
          worker.instance_eval do
            @number = 1
            @reward = 0
          end
          type = self.to_s.split("::").last.underscore
          self.post("/stations/#{station.id}/workers.json", :body => {:worker => {:number => 1, :reward => 0, :type => type}})
          station.worker = worker
        end
      end
    end
  end
end