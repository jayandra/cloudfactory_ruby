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
      attr_accessor :id, :data, :from, :to 

      case host
      when "HumanWorker"
        # Initializes new worker
        def initialize(options={})
          @station = options[:station]
          @number  = options[:number].nil? ? 1 : options[:number]
          @reward  = options[:reward]
          if @station
            resp = CF::HumanWorker.post("/stations/#{@station.id}/workers.json", :worker => {:number => @number, :reward => @reward, :type => "HumanWorker"})
            worker = CF::HumanWorker.new({})
            resp.to_hash.each_pair do |k,v|
              worker.send("#{k}=",v) if worker.respond_to?(k)
            end
            worker.station = @station
            @station.worker = worker
          end
        end
      else
        # Creates new worker 
        def self.create(options={})
          @station = options[:station]
          type = self.to_s.split("::").last.underscore
          worker = self.new
          worker.instance_eval do
            @number = 1
            @reward = 0
            if type == "google_translate_robot"
              @data = options[:data]
              @from = options[:from]
              @to = options[:to]
            end
          end
          if @station
            if type == "google_translate_robot"
              resp = self.post("/stations/#{@station.id}/workers.json", :worker => {:number => 1, :reward => 0, :type => type, :data => options[:data], :from => options[:from], :to => options[:to]})
              resp.to_hash.each_pair do |k,v|
                worker.send("#{k}=",v) if worker.respond_to?(k)
              end
              worker.station = @station
              @station.worker = worker
            end
          else
            return worker
          end
        end
      end
    end
  end
end