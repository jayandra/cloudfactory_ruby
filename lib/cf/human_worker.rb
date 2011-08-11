module CF
  class HumanWorker
    include Client
    require 'httparty'
    extend ActiveSupport::Concern
    
    # ID of "Worker" object
    attr_accessor :id
    
    # Number of worker, e.g. :number => 3
    attr_accessor :number
    
    # Reward for worker, e.g. :reward => 10 (reward unit is in cents)
    attr_accessor :reward
    
    # Station attribute for "worker" object
    attr_accessor :station
    
    # Stat Badge for "worker" object, e.g. worker = CF::HumanWorker.new({:number => 2, :reward => 20, :stat_badge => {:approval_rating => 40, :assignment_duration => 1800, :abandonment_rate => 30}})
    attr_accessor :stat_badge
    
    # Skill Badge for "worker" object
    # example:
    #   badge_settings = 
    #   {
    #       :title => 'Football Fanatic', 
    #       :description => "This qualification allows you to perform work at stations which have this badge.", 
    #       :max_badges => 3, 
    #       :test => 
    #       {
    #         :input => {:name => "Lionel Andres Messi", :country => "Argentina"},
    #         :expected_output => 
    #         [
    #           {:birthplace => "Rosario, Santa Fe, Argentina",:match_options => {:tolerance => 10, :ignore_case => true }},
    #           {:position => "CF",:match_options => {:tolerance => 1 }},
    #           {:"current-club" => "Barcelona",:match_options => {:tolerance => 1, :ignore_case => false }}
    #         ]
    #       }
    #   }
    #
    # worker = CF::HumanWorker.new({:number => 2, :reward => 20, :skill_badge => badge_settings})
    attr_accessor :skill_badges
    
    # Contains Error messages if any for "worker" object
    attr_accessor :errors
    
    # Badge setting for "worker" object
    attr_accessor :badge
    
    # ==Initializes a new "worker" object 
    # ==Usage of HumanWorker.new(hash):
    #
    # ==In Block DSL way 
    #   line = CF::Line.create("human_worker", "Survey") do |l|   
    #     CF::Station.create({:line => l, :type => "work"}) do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 10})
    #     end
    #   end
    #
    # ==In Plain Ruby way 
    #   line = CF::Line.new("human_worker", "Digitization")
    #   input_format = CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"})
    #   line.input_formats input_format
    # 
    #   station = CF::Station.new({:type => "work"})
    #   line.stations station
    # 
    #   worker = CF::HumanWorker.new({:number => 2, :reward => 20})
    #   line.stations.first.worker = worker
    
    def initialize(options={})
      @skill_badges = []
      @station = options[:station]
      @number  = options[:number].nil? ? 1 : options[:number]
      @reward  = options[:reward]
      @badge = options[:skill_badge].nil? ? nil : options[:skill_badge]
      @stat_badge = options[:stat_badge].nil? ? nil : options[:stat_badge]
      if @station
        if options[:skill_badge].nil? && options[:stat_badge].nil?
          request = 
          {
            :body => 
            {
              :api_key => CF.api_key,
              :worker => {:number => @number, :reward => @reward, :type => "HumanWorker"}
            }
          }
        else
          request = 
          {
            :body => 
            {
              :api_key => CF.api_key,
              :worker => {:number => @number, :reward => @reward, :type => "HumanWorker"},
              :skill_badge => @badge,
              :stat_badge => options[:stat_badge]
            }
          }
        end
        resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{@station.line['title'].downcase}/stations/#{@station.index}/workers.json",request)
        
        self.id =  resp.parsed_response['id']
        self.number =  resp.parsed_response['number']
        self.reward =  resp.parsed_response['reward']
        self.stat_badge =  resp.parsed_response['stat_badge'] 
        @skill_badges << resp.parsed_response['skill_badges']
        
        if resp.code != 200
          self.errors = resp.parsed_response['error']['message']
        end
        self.station = options[:station]
        self.station.worker = self
      end
    end
    
    # ==Creation a new "worker" object with Badge
    # ==Usage Example:
    # ==In Plain Ruby way 
    #   badge_settings = 
    #   {
    #       :title => 'Football Fanatic', 
    #       :description => "This qualification allows you to perform work at stations which have this badge.", 
    #       :max_badges => 3, 
    #       :test => 
    #       {
    #         :input => {:name => "Lionel Andres Messi", :country => "Argentina"},
    #         :expected_output => 
    #         [
    #           {:birthplace => "Rosario, Santa Fe, Argentina",:match_options => {:tolerance => 10, :ignore_case => true }},
    #           {:position => "CF",:match_options => {:tolerance => 1 }},
    #           {:"current-club" => "Barcelona",:match_options => {:tolerance => 1, :ignore_case => false }}
    #         ]
    #       }
    #   }
    #   line = CF::Line.new("human_worker", "Digitization")
    #   input_format = CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"})
    #   line.input_formats input_format
    # 
    #   station = CF::Station.new({:type => "work"})
    #   line.stations station
    # 
    #   worker = CF::HumanWorker.new({:number => 2, :reward => 20, :skill_badge => skill_badge})
    #   line.stations.first.worker = worker
    #
    #   line.stations.first.worker.badge = badge_settings
    def badge=(badge)
      request = 
      {
        :body => 
        {
          :api_key => CF.api_key,
          :skill_badge => badge
        }
      }
      resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{@station.line['title'].downcase}/stations/#{@station.index}/workers/#{self.id}/badge.json",request)
      self.skill_badges << resp.parsed_response['skill_badges']
    end
  end
end