module CF
  class RobotWorker
    require 'httparty'
    include Client

    # settings for robot worker of the station, e.g. robot_worker = CF::RobotWorker.new({:type => "sentiment_robot", :settings => {:document => ["{url}"], :sanitize => true}})
    attr_accessor :settings
    
    # Type of robot worker
    attr_accessor :type
    
    # Contains Error message if any 
    attr_accessor :errors
    
    # Station attribute with which robot worker will be associated
    attr_accessor :station
    
    attr_accessor :number # :nodoc:
    
    # Reward for the Robot Worker; Every Robot Worker have their fixed Reward by default
    attr_accessor :reward

    # ==Initialize new Robot Worker
    # ===Usage Example:
    #
    # ===In Block DSL way
    #   line = CF::Line.create("sentiment_robot","Digitization") do |l|
    #     CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
    #     CF::Station.create({:line => l, :type => "work"}) do |s|
    #       CF::RobotWorker.new({:station => s, :settings => {:document => "{url}", :sanitize => true}, :type => "sentiment_robot"})
    #     end
    #   end
    #
    # ==OR
    #
    # ===In Plain Ruby way 
    #   line = CF::Line.new("sentiment_robot_1","Digitization")
    #   input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
    #   line.input_formats input_format
    # 
    #   station = CF::Station.new({:type => "work"})
    #   line.stations station
    # 
    #   worker =  CF::RobotWorker.new({:settings => {:document => "{url}", :sanitize => true}, :type => "sentiment_robot"})
    #   line.stations.first.worker = worker
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
    
    
    # ==Create a new Robot Worker
    # ===Usage Example:
    #
    # ===In Block DSL way
    #   line = CF::Line.create("sentiment_robot","Digitization") do |l|
    #     CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
    #     CF::Station.create({:line => l, :type => "work"}) do |s|
    #       CF::RobotWorker.create({:station => s, :settings => {:document => "{url}", :sanitize => true}, :type => "sentiment_robot"})
    #     end
    #   end
    #
    # ==OR
    #
    # ===In Plain Ruby way 
    #   line = CF::Line.new("sentiment_robot_1","Digitization")
    #   input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
    #   line.input_formats input_format
    # 
    #   station = CF::Station.new({:type => "work"})
    #   line.stations station
    # 
    #   worker =  CF::RobotWorker.create({:settings => {:document => "{url}", :sanitize => true}, :type => "sentiment_robot"})
    #   line.stations.first.worker = worker   
    def self.create(options)
      RobotWorker.new(options)
    end
  end
end