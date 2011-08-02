module CF
  class RobotWorker
    require 'httparty'
    include Client

    # type of the station, e.g. station = Station.new(line, {:type => "Work"})
    attr_accessor :settings, :type, :errors, :station, :number, :reward

    def initialize(options={})
      @type = options[:type].nil? ? nil : options[:type].camelize
      @settings = options[:settings]
      station = options[:station]
      
      if station
        request = options[:settings].merge(:type => @type)
        resp = self.class.post("/lines/#{CF.account_name}/#{station.line_title.downcase}/stations/#{station.index}/workers.json", :worker => request)
        if resp.code != 200
          self.errors = resp.error.message
        end
        self.number = resp.number
        self.reward = resp.reward
        self.station = station
        station.worker = self
      end
    end
    
    def self.create(options)
      RobotWorker.new(options)
    end
  end
end